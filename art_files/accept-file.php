<?php
include "submit.php";
?><br/><?php
shell_exec("mkdir zwoptex_export");
move_uploaded_file($_FILES['zip']['tmp_name'],'zwoptex_export/upload.zip');
shell_exec("unzip zwoptex_export/upload.zip -d zwoptex_export/");
shell_exec("rm zwoptex_export/upload.zip");
shell_exec("rm -rf zwoptex_export/__*");
var_dump(shell_exec("TexturePacker --size-constraints POT --disable-rotation --data out.json --format spriter --sheet out.png zwoptex_export/ 2>&1"));
?><br/><br/><?php
var_dump(shell_exec("TexturePacker --size-constraints POT --disable-rotation --data out.plist --format cocos2d --sheet out.png zwoptex_export/ 2>&1"));
shell_exec("rm -rf zwoptex_export");
?>
<br/>
<br/>
<img style="border:1px solid black" src="out.png"/>
<br/>
<br/>

<script>
function saveTextAsFile() {
        var textToWrite = document.getElementById("json_out").value;
        var rtv = JSON.parse(textToWrite);
        rtv.meta.image = document.getElementById("json_out_filename").value+".png";

        var textFileAsBlob = new Blob([JSON.stringify(rtv)], {type:'text/plain'});
        var fileNameToSaveAs = document.getElementById("json_out_filename").value+".json";

        var downloadLink = document.createElement("a");
        downloadLink.download = fileNameToSaveAs;
        downloadLink.innerHTML = "Download File";
        if (window.webkitURL != null) {
                downloadLink.href = window.webkitURL.createObjectURL(textFileAsBlob);
        } else {
                downloadLink.href = window.URL.createObjectURL(textFileAsBlob);
                downloadLink.onclick = destroyClickedElement;
                downloadLink.style.display = "none";
                document.body.appendChild(downloadLink);
        }

        downloadLink.click();
}
</script>


spriter<br/>
IMAGE NAME: <input id="json_out_filename" value="out"/><br/>
<button onclick="saveTextAsFile()">SAVE</button><br/>
<textarea id="json_out" style="width:600px;height:200px" readonly>
<?=file_get_contents("out.json");?>
</textarea>
<br/>
<br/>
<br/>
<br/>
cocos2d<br/>
<textarea style="width:600px;height:50px" readonly>
<?=file_get_contents("out.plist");?>
</textarea>
