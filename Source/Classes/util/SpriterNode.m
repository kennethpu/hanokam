#import "SpriterNode.h"
#import "SpriterData.h"
#import "SpriterTypes.h"
#import "Common.h"
#import "Resource.h"

@interface CCNode_Bone : CCNode
@property(readwrite,assign) int _timeline_id, _i_timeline_key;
@end
@implementation CCNode_Bone
@synthesize _timeline_id, _i_timeline_key;
@end

@interface CCSprite_Object : CCSprite
@property(readwrite,assign) int _timeline_id, _zindex, _i_timeline_key;
@end
@implementation CCSprite_Object
@synthesize _timeline_id, _zindex, _i_timeline_key;
@end

@implementation SpriterNode {
	SpriterData *_data;
	NSMutableDictionary *_bones;
	NSMutableDictionary *_objs;
	CCNode_Bone *_root_bone;
	
	NSString *_current_anim_name;
	
	float _current_anim_time;
	int _mainline_key_index;
	int _anim_duration;
}
+(SpriterNode*)nodeFromData:(SpriterData*)data {
	return [[SpriterNode node] initFromData:data];
}
-(SpriterNode*)initFromData:(SpriterData*)data {
	_data = data;
	_bones = [NSMutableDictionary dictionary];
	_objs = [NSMutableDictionary dictionary];
	_root_bone = NULL;
	
	return self;
}

-(void)playAnim:(NSString *)anim_name {
	if (![_data anim_of_name:anim_name]) {
		NSLog(@"does not contain animation %@",anim_name);
		return;
	}
	_mainline_key_index = 0;
	_current_anim_time = 0;
	_current_anim_name = anim_name;
	_anim_duration = [_data anim_of_name:anim_name]._duration;
	
	[self update_mainline_keyframes];
	[self update_timeline_keyframes];
}

-(void)update:(CCTime)delta {
}

-(void)update_timeline_keyframes {
	for (NSNumber *itr in _bones) {
		CCNode_Bone *itr_bone = _bones[itr];
		TGSpriterTimeline *timeline = [[_data anim_of_name:_current_anim_name] timeline_key_of_id:itr_bone._timeline_id];
		TGSpriterTimelineKey *keyframe_current = [timeline keyForTime:_current_anim_time];
		
		itr_bone.position = keyframe_current.position;
		itr_bone.rotation = keyframe_current.rotation;
		itr_bone.anchorPoint = keyframe_current.anchorPoint;
		itr_bone.scaleX = keyframe_current.scaleX;
		itr_bone.scaleY = keyframe_current.scaleY;
	}
	for (NSNumber *itr in _objs) {
		CCSprite_Object *itr_obj = _objs[itr];
		TGSpriterTimeline *timeline = [[_data anim_of_name:_current_anim_name] timeline_key_of_id:itr_obj._timeline_id];
		TGSpriterTimelineKey *keyframe_current = [timeline keyForTime:_current_anim_time];
		
		itr_obj.position = keyframe_current.position;
		itr_obj.rotation = keyframe_current.rotation;
		
		itr_obj.scaleX = keyframe_current.scaleX;
		itr_obj.scaleY = keyframe_current.scaleY;
		
		TGSpriterFile *file = [_data file_for_folderid:keyframe_current.folder fileid:keyframe_current.file];
		itr_obj.texture = [_data texture];
		itr_obj.textureRect = file._rect;
		itr_obj.anchorPoint = file._pivot;
	}
}

-(void)update_mainline_keyframes {
	TGSpriterAnimation *anim = [_data anim_of_name:_current_anim_name];
	TGSpriterMainlineKey *mainline_key = [anim nth_mainline_key:_mainline_key_index];
	[self make_bone_hierarchy:mainline_key];
	[self attach_objects_to_bone_hierarchy:mainline_key];
	[self set_z_indexes:_root_bone];
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
			_bones[bone_ref_id] = [CCNode_Bone node];
		} else {
			[unadded_bones removeObject:bone_ref_id];
		}
		CCNode_Bone *itr_bone = _bones[bone_ref_id];
		itr_bone._i_timeline_key = 0;
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
	}
}

-(void)attach_objects_to_bone_hierarchy:(TGSpriterMainlineKey*)mainline_key {
	NSMutableSet *unadded_objects = [NSMutableSet setWithSet:[_objs keySet]];
	for (int i = 0; i < mainline_key._object_refs.count; i++) {
		TGSpriterObjectRef *obj_ref = [mainline_key nth_object_ref:i];
		NSNumber *obj_ref_id = [NSNumber numberWithInt:obj_ref._id];
		if (![_objs objectForKey:obj_ref_id]) {
			_objs[obj_ref_id] = [CCSprite_Object node];
		} else {
			[unadded_objects removeObject:obj_ref_id];
		}
		CCSprite_Object *itr_obj = _objs[obj_ref_id];
		itr_obj._i_timeline_key = 0;
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
	}
}

@end
