--[[
	Muxing script version 1.1
	Read everything here before using it.
--]]

-- Everything in this script is extensively documented for educational and possibly entertainment purposes.

script_name="Multiplexer 2.0"
script_description="Muxes stuff using mkvmerge"
script_author="unanimated"
script_version="1.1"
script_namespace="ua.Multiplexer20"

local haveDepCtrl,DependencyControl,depRec=pcall(require,"l0.DependencyControl")
if haveDepCtrl then
  script_version="1.1.0"
  depRec=DependencyControl{feed="https://raw.githubusercontent.com/TypesettingTools/unanimated-Aegisub-Scripts/master/DependencyControl.json"}
end

function mux(subs,sel)
	ADD=aegisub.dialog.display
	ADP=aegisub.decode_path
	ak=aegisub.cancel

	muxconfig=ADP("?user").."\\mux-config.conf"
	vpath=ADP("?video").."\\"
	spath=ADP("?script").."\\"
	scriptname=aegisub.file_name()
	videoname=nil
	
	show,ep=scriptname:match("^(.-)%s*(%d+)%.ass")
	
	if ep==nil then
	  show,ep=scriptname:match("^(.-)%s*(OVA)$")
	  if ep==nil then show=scriptname:gsub("%.ass","") ep="" end
	end

    file=io.open(muxconfig)
    if file~=nil then
	konf=file:read("*all")
	io.close(file)
	mmgpath=konf:match("mmgpath:(.-)\n")
	fontpath=konf:match("ffpath:(.-)\n")
	tag=konf:match("tag:(.-)\n")
	endtag=konf:match("endtag:(.-)\n")
	if endtag == nil then endtag = "" end
	sfvpath=konf:match("enfis:(.-)\n")
	xdpath=konf:match("xdelta:(.-)\n")
	lang1=konf:match("lang1:(.-)\n")
	lang2=konf:match("lang2:(.-)\n")
	crc=detf(konf:match("crc:(.-)\n"))
	patch=detf(konf:match("patch:(.-)\n"))
	delete=detf(konf:match("delete:(.-)\n"))
	cmdopen=detf(konf:match("cmdopen:(.-)\n"))
    else
	mmgpath=""
	fontpath="custom path:"
	tag="[SomeShitGroup]"
	endtag=""
	sfvpath="download from http://unanimated.xtreemhost.com/SFV_Checker.zip or elsewhere"
	xdpath=""
	lang1="eng"
	lang2=""
	crc=false
	patch=false
	delete=true
	cmdopen=false
    end

    for i=1,#subs do
	l=subs[i]
	if l.class=="info" then
	  if l.key=="Video File" then videoname=l.value end
	  if l.key=="Title" then title=l.value end
	end
	if l.class~="info" then break end
    end
    
    if videoname==nil then videoname=aegisub.project_properties().video_file:gsub("^.*\\","") end
    
    if title==nil or title=="Default Aegisub file" then title=show end
    if title:match("%d+$") then ep=title:match("(%d+)$") title=title:gsub("%s?%-?%s?%d+$","") end
    
    if tag~="" then tag2=tag.." " else tag2="" end
    if ep~="" then ep2=" - "..ep else ep2="" end
    if endtag~="" then endtag2=" "..endtag else endtag2="" end
    mvideo=tag2..title..ep2..endtag2..".mkv"
    
    if mvideo==videoname then mvideo=mvideo:gsub("%.mkv","_muxed.mkv") end
    
    ch_name=spath..scriptname:gsub("%.ass",".xml")
    file=io.open(ch_name)
    if file==nil then ch_name="" else file:close() end
    
    GUI={
	{x=0,y=0,class="label",label="mkvmerge.exe:"},		{x=1,y=0,width=11,class="edit",name="mmgpath",value=mmgpath},
	{x=0,y=1,class="label",label="Fonts folder:"},
	{x=1,y=1,width=2,class="dropdown",name="ff",value=fontpath,items={"script folder","script folder/fonts","script folder/ep number","video folder","video folder/fonts","video folder/ep number","custom path:"}},
	{x=3,y=1,width=9,class="edit",name="fontspath",value=fontspath or "(only custom path goes here)"},
	{x=0,y=2,class="label",label="Group tag:"},		{x=1,y=2,width=11,class="edit",name="tag",value=tag},
	{x=0,y=3,class="label",label="End tag:"},		{x=1,y=3,width=11,class="edit",name="endtag",value=endtag},
	{x=0,y=4,class="label",label="Enfis_SFV.exe:"},	{x=1,y=4,width=11,class="edit",name="enfis",value=sfvpath},
	{x=0,y=5,class="label",label="xdelta(3).exe:"},	{x=1,y=5,width=11,class="edit",name="xdelta",value=xdpath},
	
	{x=1,y=6,width=7,class="label",label="'Save settings' saves the above + languages + the bottom 4 checkboxes."},
	
	{x=0,y=7,class="label",label="Muxed video name:"},	{x=1,y=7,width=11,class="edit",name="mvid",value=mvideo},
	{x=0,y=8,class="label",label="Source video:"},		{x=1,y=8,width=6,class="edit",name="vid",value=videoname},
	{x=7,y=8,class="checkbox",name="noA",label="-A ",hint="no audio"},
	{x=8,y=8,class="checkbox",name="noS",label="-S",hint="no subtitles"},
	{x=9,y=8,class="checkbox",name="noM",label="-M ",hint="no attachments"},
	{x=10,y=8,class="checkbox",name="noC",label="nc",hint="no chapters"},
	{x=11,y=8,class="checkbox",name="noT",label="nt",hint="no tags"},
	{x=0,y=9,class="label",label="File/segment title:"},	{x=1,y=9,width=4,class="edit",name="vtitle"},
	{x=5,y=9,width=3,class="checkbox",name="VO",label="Video options:",hint="additional input video options"},
	{x=8,y=9,width=4,class="edit",name="vopt"},
	
	{x=0,y=10,class="label",label="Subtitle 1:"},		{x=1,y=10,width=8,class="edit",name="subs",value=spath..scriptname},
	{x=9,y=10,width=3,class="checkbox",name="defsub",label="Set as default",hint="You can use this when orginal video already has subs"},
	
	{x=1,y=11,class="label",label="Subtitle 1 title:"},{x=2,y=11,width=5,class="edit",name="subname1",value=""},
	{x=7,y=11,width=2,class="label",label="    Language:  "},{x=9,y=11,width=3,class="edit",name="lang1",value=lang1 or ""},
	
	{x=0,y=12,class="checkbox",name="sub2",label="Subtitle 2:"},{x=1,y=12,width=11,class="edit",name="subs2",value=""},
	{x=0,y=13,class="label",label="Subtitle 2 title:"},{x=1,y=13,width=6,class="edit",name="subname2",value=""},
	{x=7,y=13,width=2,class="label",label="    Language:  "},{x=9,y=13,width=3,class="edit",name="lang2",value=lang2 or ""},
	
	{x=0,y=14,class="checkbox",name="ch",label="Chapters",value=false},
	{x=1,y=14,width=11,class="edit",name="chapters",value=ch_name},
	
	{x=0,y=15,class="checkbox",name="sfv",label="Create CRC",value=crc,hint="requires Enfis_SFV.exe and lua for windows"},
	{x=1,y=15,class="checkbox",name="xd",label="Create xdelta patch",value=patch,hint="requires Enfis_SFV.exe, xdelta3.exe, lua for win"},
	{x=3,y=15,width=2,class="checkbox",name="del",label="Delete temporary files when done      ",value=delete},
	{x=5,y=15,width=4,class="checkbox",name="cmd",label="Keep cmd window open",value=cmdopen},
	
	{x=9,y=15,width=3,class="label",label="      [ Multiplexer v"..script_version.." ]"},
    }
    
    repeat
    if P=="mkvmerge" then
	mmg_path=aegisub.dialog.open("mkvmerge.exe","",spath,"*.exe",false,true)
	gui("mmgpath",mmg_path)
    end
    if P=="fonts" then
	ff_path=aegisub.dialog.open("Fonts folder (Select any file in it)","",spath,"",false,true)
	if ff_path then ff_path=ff_path:gsub("\\[%w%s]+%.%w+$","\\") end
	gui("fontspath",ff_path)
    end
    if P=="Enfis" then
	sfv_path=aegisub.dialog.open("Enfis_SFV.exe","",spath,"*.exe",false,true)
	gui("enfis",sfv_path)
    end
    if P=="xdelta" then
	xd_path=aegisub.dialog.open("xdelta(3).exe","",spath,"*.exe",false,true)
	gui("xdelta",xd_path)
    end
    if P=="Subs 2" then
	s2_path=aegisub.dialog.open("Secondary subtitle file","",spath,"*.ass",false,true)
	gui("subs2",s2_path)
    end
    if P=="Chapters" then
	ch_path=aegisub.dialog.open("Chapters","",spath,"*.xml",false,true)
	gui("chapters",ch_path)
    end
    
    if P=="Save settings" then
	kcrc=tf(res.sfv)
	kxdel=tf(res.xd)
	kdel=tf(res.del)
	kcmd=tf(res.cmd)
	
	konf="mmgpath:"..res.mmgpath.."\nffpath:"..res.ff.."\ntag:"..res.tag.."\nendtag:"..res.endtag.."\nenfis:"..res.enfis.."\nxdelta:"..res.xdelta.."\nlang1:"..res.lang1.."\nlang2:"..res.lang2.."\ncrc:"..kcrc.."\npatch:"..kxdel.."\ndelete:"..kdel.."\ncmdopen:"..kcmd.."\n"
	
	file=io.open(muxconfig,"w")
	file:write(konf)
	file:close()
	
	for k,v in ipairs(GUI) do v.value=res[v.name] end
	
	ADD({{class="label",label="Settings saved to:\n"..muxconfig}},{"OK"},{close='OK'})
    end
    
    P,res=ADD(GUI,{"Mux","mkvmerge","fonts","Enfis","xdelta","Subs 2","Chapters","Save settings","Cancel"},{ok='Mux',close='Cancel'})
    
    until P=="Mux" or P=="Cancel"
    
    if P=="Cancel" then ak() end
    
    aegisub.progress.title("Preparing files for muxing...")
    
    video=res.vid
    mvideo=res.mvid
    subname1=res.subname1
    subname2=res.subname2
    lang1=res.lang1
    lang2=res.lang2
    fontspath=res.fontspath
    endtag=res.endtag
    if res.vtitle~="" then vtitle=" --title "..quo(res.vtitle) else vtitle="" end
    
    if res.xd then res.sfv=true end
    
    if res.mmgpath:match("mmg.exe") then t_error("ERROR: Youre doing it wrong.\n'mmg.exe' is not 'mkvmerge.exe'.",true) end
    if not res.mmgpath:match("mkvmerge.exe") then t_error("ERROR:\n'"..res.mmgpath.."' is not a valid 'mkvmerge.exe' file.",true) end
    
    if res.sfv then
	if res.enfis=="" then
	  t_error("Enfis_SFV.exe not specified.\nProceeding without CRC.")
	  bat_crc=""
	else
	  file=io.open(res.enfis)
	  if file==nil then t_error("FILE NOT FOUND!\n"..res.enfis,true) else file:close() end
	  
	  mvideo=mvideo:gsub("%.mkv"," [CRC].mkv")
	  
	  bat_crc=quo(res.enfis).." -f=\"whatisthisidonteven.sfv\" "..quo(mvideo).."\ncall sfv.lua\ncall patchrel\ncall xdbatch\n"
	  
	  luavpath=vpath:gsub("\\","\\\\")
	  sfvlua="file=io.open(\""..luavpath.."whatisthisidonteven.sfv\")\nsfvtext=file:read(\"*all\")\nfile:close()\ncrc=sfvtext:match(\"%s+(%x+)%s*$\")\nif crc==nil then crc=\"00000000\" end\nvideo=\""..mvideo.."\"\ncrc_name=video:gsub(\"%[CRC%]\",\"[\"..crc..\"]\")\ncrctext=\"rename \\\""..mvideo.."\\\" \\\"\"..crc_name..\"\\\"\"\nfile=io.open(\""..luavpath.."patchrel.bat\",\"w\")\nfile:write(crctext)\nfile:close()\n"
	  
	  -- LOGICA ACTUALIZADA DE XDELTA AQUI
	  if res.xd then
	    file=io.open(res.xdelta)
	    if file==nil then
	      t_error("FILE NOT FOUND!\n"..res.xdelta.."\nProceeding without patching.")
	      xdt=""
	      bat_crc=bat_crc:gsub("\ncall xdbatch","")
	    else 
	      luaxd=res.xdelta:gsub("\\","\\\\")
	      local outer_video = res.vid
	      local xd_name = show..ep..".xdelta"
	      local zip_name = show..ep.."_patch.zip"
	      
	      xdt = "\n"
	      -- Scripts de aplicación con variables correctas dinámicas
	      xdt = xdt .. "local apply_bat = \"xdelta3.exe -d -s \\\"" .. outer_video .. "\\\" \\\"" .. xd_name .. "\\\" \\\"\" .. crc_name .. \"\\\"\\r\\npause\\r\\n\"\n"
	      xdt = xdt .. "local apply_sh = \"#!/bin/bash\\nxdelta3 -d -s \\\"" .. outer_video .. "\\\" \\\"" .. xd_name .. "\\\" \\\"\" .. crc_name .. \"\\\"\\n\"\n"
	      
	      -- Escribir patch_win.bat y patch_lin.sh en el directorio de video
	      xdt = xdt .. "local f = io.open(\"" .. luavpath .. "patch_win.bat\", \"wb\")\n"
	      xdt = xdt .. "if f then f:write(apply_bat); f:close() end\n"
	      xdt = xdt .. "f = io.open(\"" .. luavpath .. "patch_lin.sh\", \"wb\")\n"
	      xdt = xdt .. "if f then f:write(apply_sh); f:close() end\n"
	      
	      -- Construir el archivo batch de automatización final
	      xdt = xdt .. "local xdtext = \"\"\n"
	      xdt = xdt .. "xdtext = xdtext .. \"call \\\"" .. luaxd .. "\\\" -f -s \\\"" .. outer_video .. "\\\" \\\"\" .. crc_name .. \"\\\" \\\"" .. xd_name .. "\\\"\\n\"\n"
	      xdt = xdt .. "xdtext = xdtext .. \"copy \\\"" .. luaxd .. "\\\" xdelta3.exe >nul\\n\"\n"
	      
	      -- Usar PowerShell para crear el zip e incluir todos los archivos
	      xdt = xdt .. "xdtext = xdtext .. \"powershell Compress-Archive -Path '" .. xd_name .. "', 'patch_win.bat', 'patch_lin.sh', 'xdelta3.exe' -DestinationPath '" .. zip_name .. "' -Force\\n\"\n"
	      
	      -- Borrar archivos sueltos SOLO si el .zip se creó correctamente
	      xdt = xdt .. "xdtext = xdtext .. \"if exist \\\"" .. zip_name .. "\\\" (\\n\"\n"
	      xdt = xdt .. "xdtext = xdtext .. \"    del \\\"" .. xd_name .. "\\\"\\n\"\n"
	      xdt = xdt .. "xdtext = xdtext .. \"    del patch_win.bat\\n\"\n"
	      xdt = xdt .. "xdtext = xdtext .. \"    del patch_lin.sh\\n\"\n"
	      xdt = xdt .. "xdtext = xdtext .. \"    del xdelta3.exe\\n\"\n"
	      xdt = xdt .. "xdtext = xdtext .. \") else (\\n\"\n"
	      xdt = xdt .. "xdtext = xdtext .. \"    echo Failed to create ZIP.\\n\"\n"
	      xdt = xdt .. "xdtext = xdtext .. \")\\n\"\n"
	      
	      xdt = xdt .. "f = io.open(\"" .. luavpath .. "xdbatch.bat\", \"w\")\n"
	      xdt = xdt .. "if f then f:write(xdtext); f:close() end\n"
	    end
	  else
	    xdt=""
	    bat_crc=bat_crc:gsub("\ncall xdbatch","")
	  end
	  
	  file=io.open(vpath.."sfv.lua","w")
	  file:write(sfvlua..xdt)
	  file:close()
	  
	end
    else
	bat_crc=""
    end
    
    if res.ff=="script folder" then ffpath=spath end
    if res.ff=="script folder/fonts" then ffpath=spath.."fonts" end
    if res.ff=="script folder/ep number" then ffpath=spath..ep end
    if res.ff=="video folder" then ffpath=vpath end
    if res.ff=="video folder/fonts" then ffpath=vpath.."fonts" end
    if res.ff=="video folder/ep number" then ffpath=vpath..ep end
    if res.ff=="custom path:" then ffpath=res.fontspath end
    ffpath=ffpath.."\\"
    
    if res.ch then
	bat_chap="--chapters "..quo(res.chapters).." "
	
	file=io.open(res.chapters)
	if file==nil then t_error("Chapters not found:\n"..res.chapters.."\nProceeding without.") bat_chap="" else file:close() end
    else
	bat_chap=""
    end
    
    list="cd /d "..quo(ffpath).."\ndir /b>files.txt\ndel list.bat"
    file=io.open(ffpath.."list.bat","w")
    file:write(list)
    file:close()
    
    exffpath=ffpath:gsub("%=","^=")
    os.execute("\""..exffpath.."list.bat\"")
    
    file=io.open(ffpath.."files.txt")
    fontext=file:read("*all")
    file:close()
    
    fontslist={}
    
    for line in fontext:gmatch("(.-)\n") do table.insert(fontslist,line) end
    
    muxbatch="" fc=0
    
    for i=1,#fontslist do
	fline=fontslist[i]
	if fline:match("%.[TtOo][Tt][Ff]$") then fc=fc+1
	muxbatch=muxbatch.."--attachment-mime-type application/x-truetype-font --attach-file "..quo(fline).." " end
    end
    
    if muxbatch=="" then t_error("Warning: No fonts found in "..ffpath) end
    
    if subname1~="" then tn1=" --track-name 0:"..quo(subname1) else tn1="" end
    if lang1~="" then ln1=" --language 0:"..lang1 else ln1="" end
    
    if res.sub2 then
	if subname2~="" then tn2=" --track-name 0:"..quo(subname2) else tn2="" end
	if lang2~="" then ln2=" --language 0:"..lang2 else ln2="" end
	subs2=tn2..ln2.." "..quo(res.subs2)
    else
	subs2=""
    end
    
    if res.defsub then defsub=" --default-track 0:true" else defsub="" end
    vopt=""
    if res.noA then vopt=vopt.." -A" end
    if res.noS then vopt=vopt.." -S" end
    if res.noM then vopt=vopt.." -M" end
    if res.noC then vopt=vopt.." --no-chapters" end
    if res.noT then vopt=vopt.." -T --no-global-tags" end
    if res.VO then vopt=vopt.." "..res.vopt end
    muxbatch=quo(res.mmgpath)..vtitle.." -o "..quo(vpath..mvideo)..vopt.." "..quo(vpath..video)..tn1..ln1..defsub.." "..quo(res.subs)..subs2.." "..bat_chap..muxbatch
    
    file=io.open(ffpath.."mux.bat","w")
    file:write(muxbatch)
    file:close()
    
    if res.del then
	delete="\ndel \""..ffpath.."files.txt\"\ndel \""..ffpath.."mux.bat\"\ndel \"patchrel.bat\"\ndel \"xdbatch.bat\"\ndel \"sfv.lua\"\ndel \"whatisthisidonteven.sfv\"\ndel \"muxing.bat\"\n"
    else
	delete=""
    end
    
    if res.cmd then pause="pause" else pause="" end
    
    BAT="cd /d "..quo(ffpath).."\ncall mux.bat\ncd /d "..quo(vpath).."\n"..bat_crc..pause..delete
    
    batch=vpath.."muxing.bat"
    
    local xfile=io.open(batch,"w")
    xfile:write(BAT)
    xfile:close()
    
    summary="Files to mux:\n\nVideo file:        "..video.."\nSubtitle file 1:  "..res.subs.."\nSubtitle file 2:  "..res.subs2.."\nFonts to mux:  "..fc.."\n\nMuxed file:      "..mvideo.."\n\nBatch file:       "..batch.."\n\nYou can mux now or run this batch file later.\nIf muxing from Aegisub doesn't work,\njust run the batch file.\n\nMux now?"
    
    P=ADD({{class="label",label=summary}},{"Yes","No"},{ok='Yes',close='No'})
    if P=="Yes" then
	aegisub.progress.title("Muxing...")
	
	batch=batch:gsub("%=","^=")
	
	os.execute(quo(batch))
    end
end

function gui(a,b)
  for k,v in ipairs(GUI) do
    if b==nil then b="" end
    if v.name==a then v.value=b else v.value=res[v.name] end
  end
end

function t_error(message,cancel)
  ADD({{class="label",label=message}},{"OK"},{close='OK'})
  if cancel then ak() end
end

function quo(x)    x="\""..x.."\""    return x   end

function tf(val)
	if val==true then ret="true"
	elseif val==false then ret="false"
	else ret=val end
	return ret
end

function detf(txt)
	if txt=="true" then ret=true
	elseif txt=="false" then ret=false
	else ret=txt end
	return ret
end

function esc(str) str=str:gsub("[%%%(%)%[%]%.%-%+%*%?%^%$]","%%%1") return str end

function logg(m) m=m or "nil" aegisub.log("\n "..m) end

if haveDepCtrl then depRec:registerMacro(mux) else aegisub.register_macro(script_name,script_description,mux) end