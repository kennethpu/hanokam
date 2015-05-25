#import "SpriterNode.h"
#import "SpriterData.h"
#import "SpriterTypes.h"
#import "SpriterUtil.h"

@interface CCNode_Bone : CCNode
@property(readwrite,assign) int _timeline_id;
@end
@implementation CCNode_Bone
@synthesize _timeline_id;
@end

@interface CCSprite_Object : CCSprite
@property(readwrite,assign) int _timeline_id, _zindex;
@end
@implementation CCSprite_Object
@synthesize _timeline_id, _zindex;
@end

@implementation SpriterNode {
	SpriterData *_data;
	NSMutableDictionary *_bones;
	NSMutableDictionary *_objs;
	
	NSMutableDictionary *_unused_bones;
	NSMutableDictionary *_unused_objs;
	
	CCNode_Bone *_root_bone;
	
	NSString *_current_anim_name;
	
	float _current_anim_time;
	int _anim_duration;
	BOOL _repeat_anim;
	BOOL _anim_finished;
	
	NSString *_on_finish_play_anim, *_current_playing;
	
	long _last_bone_structure_hash;
}

-(BOOL)current_anim_repeating { return _repeat_anim; }
-(BOOL)current_anim_finished { return _anim_finished; }

+(SpriterNode*)nodeFromData:(SpriterData*)data {
	return [[SpriterNode node] initFromData:data];
}
-(SpriterNode*)initFromData:(SpriterData*)data {
	_data = data;
	_bones = [NSMutableDictionary dictionary];
	_objs = [NSMutableDictionary dictionary];
	_root_bone = NULL;
	
	_unused_bones = [NSMutableDictionary dictionary];
	_unused_objs = [NSMutableDictionary dictionary];
	
	return self;
}

-(void)p_play_anim:(NSString*)anim repeat:(BOOL)repeat {
	_on_finish_play_anim = NULL;
	if(_current_playing != anim) {
		_current_playing = anim;
		[self playAnim:anim repeat:repeat];
	}
}

-(void)p_play_anim:(NSString*)anim1 on_finish_anim:(NSString*)anim2 {
	_current_playing = anim1;
	[self playAnim:anim1 repeat:NO];
	_on_finish_play_anim = anim2;
}

-(void)playAnim:(NSString *)anim_name repeat:(BOOL)repeat {
	if (![_data anim_of_name:anim_name]) {
		NSLog(@"does not contain animation %@",anim_name);
		return;
	}
	_current_anim_time = 0;
	_current_anim_name = anim_name;
	_anim_duration = (int)[_data anim_of_name:anim_name]._duration;
	_repeat_anim = repeat;
	_anim_finished = NO;
	
	[self update_mainline_keyframes];
	[self update_timeline_keyframes];
}

-(void)update:(CCTime)delta {
	_current_anim_time += delta * 1000;
	if (_current_anim_time > _anim_duration) {
		if (_repeat_anim) {
			_current_anim_time = _current_anim_time-_anim_duration;
		} else {
			_current_anim_time = _anim_duration;
			_anim_finished = YES;
		}
	}
	[self update_mainline_keyframes];
	[self update_timeline_keyframes];
}

float get_t_for_keyframes(TGSpriterTimelineKey *keyframe_current, TGSpriterTimelineKey *keyframe_next, float _current_anim_time, float _anim_duration, bool _repeat_anim) {
	float t;
	if (keyframe_current.startsAt > keyframe_next.startsAt) {
		if (_repeat_anim) {
			t = clampf((_current_anim_time-keyframe_current.startsAt)/(_anim_duration-keyframe_current.startsAt)  + keyframe_next.startsAt, 0, 1);
		} else {
			t = 0;
			keyframe_next = keyframe_current;
		}

	} else {
		t = clampf((_current_anim_time-keyframe_current.startsAt)/(keyframe_next.startsAt-keyframe_current.startsAt),0,1);
	}
	return t;
}

-(void)update_timeline_keyframes {
	for (NSNumber *itr in _bones) {
		CCNode_Bone *itr_bone = _bones[itr];
		TGSpriterTimeline *timeline = [[_data anim_of_name:_current_anim_name] timeline_key_of_id:itr_bone._timeline_id];
		TGSpriterTimelineKey *keyframe_current = [timeline keyForTime:_current_anim_time];
		TGSpriterTimelineKey *keyframe_next = [timeline nextKeyForTime:_current_anim_time];
		
		float t = get_t_for_keyframes(keyframe_current, keyframe_next, _current_anim_time, _anim_duration, _repeat_anim);
		
		[self interpolate:itr_bone from:keyframe_current to:keyframe_next t:t];
	}
	for (NSNumber *itr in _objs) {
		CCSprite_Object *itr_obj = _objs[itr];
		TGSpriterTimeline *timeline = [[_data anim_of_name:_current_anim_name] timeline_key_of_id:itr_obj._timeline_id];
		
		TGSpriterTimelineKey *keyframe_current = [timeline keyForTime:_current_anim_time];
		TGSpriterTimelineKey *keyframe_next = [timeline nextKeyForTime:_current_anim_time];
		
		float t = get_t_for_keyframes(keyframe_current, keyframe_next, _current_anim_time, _anim_duration, _repeat_anim);
		[self interpolate:itr_obj from:keyframe_current to:keyframe_next t:t];
		
		TGSpriterFile *file = [_data file_for_folderid:keyframe_current.folder fileid:keyframe_current.file];
		itr_obj.texture = [_data texture];
		itr_obj.textureRect = file._rect;
	}
}

-(void)interpolate:(CCNode*)node from:(TGSpriterTimelineKey*)from to:(TGSpriterTimelineKey*)to t:(float)t{
	node.position = ccp(scubic_interp(from.position.x, to.position.x, t),scubic_interp(from.position.y, to.position.y, t));
	node.rotation = scubic_angular_interp(from.rotation, to.rotation, t);
	node.scaleX = scubic_interp(from.scaleX, to.scaleX, t);
	node.scaleY = scubic_interp(from.scaleY, to.scaleY, t);
	node.opacity = scubic_interp(from.alpha, to.alpha, t);
	node.anchorPoint = ccp(scubic_interp(from.anchorPoint.x, to.anchorPoint.x, t),scubic_interp(from.anchorPoint.y, to.anchorPoint.y, t));

}

-(void)update_mainline_keyframes {
	TGSpriterAnimation *anim = [_data anim_of_name:_current_anim_name];
	TGSpriterMainlineKey *mainline_key;
	for (int i = 0; i < [anim._mainline_keys count]; i++) {
		if ([anim nth_mainline_key:i]._start_time > _current_anim_time) {
			break;
		}
		mainline_key = [anim nth_mainline_key:i];
	}
	
	if (_last_bone_structure_hash != mainline_key._hash) {
		[self make_bone_hierarchy:mainline_key];
		[self attach_objects_to_bone_hierarchy:mainline_key];
		[self set_z_indexes:_root_bone];
		
		_last_bone_structure_hash = mainline_key._hash;
	}
}

-(int)set_z_indexes:(CCNode*)itr {
	if ([itr isKindOfClass:[CCNode_Bone class]]) {
		int z = 0;
		for (CCNode *child in itr.children) {
			z = MAX([self set_z_indexes:child], z);
		}
		[itr setZOrder:z];
		return z;
		
	} else {
		CCSprite_Object *itr_obj = (CCSprite_Object*)itr;
		[itr setZOrder:itr_obj._zindex];
		return itr_obj._zindex;
	}
}

-(void)make_bone_hierarchy:(TGSpriterMainlineKey*)mainline_key {
	NSMutableSet *unadded_bones = [NSMutableSet setWithSet:[_bones keySet]];
	
	for (int i = 0; i < mainline_key._bone_refs.count; i++) {
		TGSpriterObjectRef *bone_ref = [mainline_key nth_bone_ref:i];
		NSNumber *bone_ref_id = [NSNumber numberWithInt:bone_ref._id];
		if (![_bones objectForKey:bone_ref_id]) {
			if ([_unused_bones objectForKey:bone_ref_id] == NULL) {
				_bones[bone_ref_id] = [CCNode_Bone node];
				
			} else {
				_bones[bone_ref_id] = _unused_bones[bone_ref_id];
				[_unused_bones removeObjectForKey:bone_ref_id];
			}
			
		} else {
			[unadded_bones removeObject:bone_ref_id];
		}
		CCNode_Bone *itr_bone = _bones[bone_ref_id];
		itr_bone._timeline_id = bone_ref._timeline_id;
	}
	
	for (int i = 0; i < mainline_key._bone_refs.count; i++) {
		TGSpriterObjectRef *bone_ref = [mainline_key nth_bone_ref:i];
		NSNumber *bone_ref_id = [NSNumber numberWithInt:bone_ref._id];
		CCNode_Bone *itr_bone = _bones[bone_ref_id];
		
		[itr_bone removeFromParent];
		if (bone_ref._is_root) {
			_root_bone = itr_bone;
			[self addChild:_root_bone];
		} else {
			CCNode_Bone *itr_bone_parent = _bones[[NSNumber numberWithInt:bone_ref._parent_bone_id]];
			[itr_bone_parent addChild:itr_bone];
		}
		
	}
	
	for (NSNumber *itr in unadded_bones) {
		CCNode_Bone *itr_bone = _bones[itr];
		[itr_bone removeFromParent];
		[_bones removeObjectForKey:itr];
		_unused_bones[itr] = itr_bone;
	}
}

-(void)attach_objects_to_bone_hierarchy:(TGSpriterMainlineKey*)mainline_key {
	NSMutableSet *unadded_objects = [NSMutableSet setWithSet:[_objs keySet]];
	for (int i = 0; i < mainline_key._object_refs.count; i++) {
		TGSpriterObjectRef *obj_ref = [mainline_key nth_object_ref:i];
		NSNumber *obj_ref_id = [NSNumber numberWithInt:obj_ref._id];
		if (![_objs objectForKey:obj_ref_id]) {
			if ([_unused_objs objectForKey:obj_ref_id] == NULL) {
				_objs[obj_ref_id] = [CCSprite_Object node];
			} else {
				_objs[obj_ref_id] = _unused_objs[obj_ref_id];
				[_unused_objs removeObjectForKey:obj_ref_id];
			}
		} else {
			[unadded_objects removeObject:obj_ref_id];
		}
		CCSprite_Object *itr_obj = _objs[obj_ref_id];
		[itr_obj removeFromParent];
		itr_obj._timeline_id = obj_ref._timeline_id;
		itr_obj._zindex = obj_ref._zindex;
		
		CCNode_Bone *itr_bone_parent = _bones[[NSNumber numberWithInt:obj_ref._parent_bone_id]];
		[itr_bone_parent addChild:itr_obj z:itr_obj._zindex];
	}
	
	for (NSNumber *itr in unadded_objects) {
		CCSprite_Object *itr_objs = _objs[itr];
		[itr_objs removeFromParent];
		[_objs removeObjectForKey:itr];
		_unused_objs[itr] = itr_objs;
	}
}

@end
