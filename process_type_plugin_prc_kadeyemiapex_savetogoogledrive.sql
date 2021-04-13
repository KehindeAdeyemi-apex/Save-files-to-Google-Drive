prompt --application/set_environment
set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
--
-- ORACLE Application Express (APEX) export file
--
-- You should run the script connected to SQL*Plus as the Oracle user
-- APEX_200200 or as the owner (parsing schema) of the application.
--
-- NOTE: Calls to apex_application_install override the defaults below.
--
--------------------------------------------------------------------------------
begin
wwv_flow_api.import_begin (
 p_version_yyyy_mm_dd=>'2020.10.01'
,p_release=>'20.2.0.00.20'
,p_default_workspace_id=>12061588927802292
,p_default_application_id=>199
,p_default_id_offset=>0
,p_default_owner=>'HUMBRE'
);
end;
/
 
prompt APPLICATION 199 - Experiencing APEX Plugins (SavetoGoogleDrive)
--
-- Application Export:
--   Application:     199
--   Name:            Experiencing APEX Plugins (SavetoGoogleDrive)
--   Date and Time:   07:04 Tuesday April 13, 2021
--   Exported By:     HUMBRE
--   Flashback:       0
--   Export Type:     Component Export
--   Manifest
--     PLUGIN: 35021698432080344
--   Manifest End
--   Version:         20.2.0.00.20
--   Instance ID:     9518101442230345
--

begin
  -- replace components
  wwv_flow_api.g_mode := 'REPLACE';
end;
/
prompt --application/shared_components/plugins/process_type/prc_kadeyemiapex_savetogoogledrive
begin
wwv_flow_api.create_plugin(
 p_id=>wwv_flow_api.id(35021698432080344)
,p_plugin_type=>'PROCESS TYPE'
,p_name=>'PRC.KADEYEMIAPEX.SAVETOGOOGLEDRIVE'
,p_display_name=>'Save Files to Google Drive'
,p_supported_ui_types=>'DESKTOP'
,p_supported_component_types=>'APEX_APPLICATION_PAGE_PROC:APEX_APPL_AUTOMATION_ACTIONS'
,p_plsql_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'-- =============================================================================',
'--',
'--  Author: Kehinde Adeyemi',
'--  Date: 27.03.2021',
'--  This plug-in lets users upload files to google drive.',
'--  ',
'--',
'--  License: MIT',
'--',
'--  GitHub: https://github.com/',
'--',
'--',
'-- Modified on 13.04.2021 to ensure metadata is displayed correctly after upload',
'--',
'-- =============================================================================',
'',
'function render',
'  ( p_process in apex_plugin.t_process',
'  , p_plugin   in apex_plugin.t_plugin',
'  )',
'return apex_plugin.t_process_exec_result ',
'as',
'    l_result                 apex_plugin.t_process_exec_result;',
'',
'    -- general attributes',
'   l_refresh_token         p_process.attribute_01%type := p_process.attribute_01;',
'   l_client_id             p_process.attribute_02%type := p_process.attribute_02;',
'   l_client_secret         p_process.attribute_03%type := p_process.attribute_03;',
'   l_api_key               p_process.attribute_04%type := p_process.attribute_04;',
'   l_permission_role       p_process.attribute_05%type := p_process.attribute_05;',
'   l_permission_type       p_process.attribute_06%type := p_process.attribute_06;',
'   l_email_address         p_process.attribute_07%type := p_process.attribute_07;',
'   l_domain                p_process.attribute_08%type := p_process.attribute_08;',
'   l_filebrowse_item       p_process.attribute_09%type := p_process.attribute_09;',
'   l_generated_urls        p_process.attribute_10%type := p_process.attribute_10;',
'',
'',
'   l_response_authclob   CLOB;',
'   l_rest_authurl        VARCHAR2 (1000);',
'   l_parm_names      apex_application_global.vc_arr2;',
'   l_parm_values     apex_application_global.vc_arr2;',
'   l_access_token    varchar2(1000);',
'   l_rest_url        VARCHAR2 (1000);',
'   l_payload         CLOB;',
'   l_response_clob   CLOB;',
'   l_fileid         VARCHAR2(1000);',
'   l_ext              VARCHAR2(20);',
'   l_mimetype        VARCHAR2(500);',
'   v_sqlerrm         VARCHAR2(1000);',
'   l_file_link       VARCHAR2(500);',
'   l_rest_linkurl        VARCHAR2 (1000);',
'   l_response_linkclob   CLOB;',
'   l_preview_url     VARCHAR2(500);',
'',
'',
'    /*****Added 13th Apr 2021*******/',
'   l_rest_nameurl        VARCHAR2 (1000);',
'   l_response_nameclob   CLOB;',
'   ',
'   ',
'   l_rest_permissionurl        VARCHAR2 (1000);',
'   l_permissionpayload         CLOB;',
'   l_response_permissionclob   CLOB;',
'',
'   l_preview_urls    VARCHAR2(4000);',
'   l_file_names      apex_application_global.vc_arr2;',
'   l_count           NUMBER:=0;',
'BEGIN',
'-----------------Get access token',
'BEGIN',
'   l_parm_names (1) := ''refresh_token'';',
'   l_parm_values (1) := l_refresh_token;',
'   l_parm_names (2) := ''client_id'';',
'   l_parm_values (2) := l_client_id;',
'   l_parm_names (3) := ''client_secret'';',
'   l_parm_values (3) := l_client_secret;',
'   l_parm_names (4) := ''grant_type'';',
'   l_parm_values (4) := ''refresh_token'';',
'   l_rest_authurl := ''https://www.googleapis.com/oauth2/v4/token'';',
'   apex_web_service.g_request_headers.delete ();',
'   apex_web_service.g_request_headers (1).name := ''Content-Type'';',
'   apex_web_service.g_request_headers (1).value := ''application/x-www-form-urlencoded'';',
'   l_response_clob :=',
'      apex_web_service.make_rest_request (p_url           => l_rest_authurl,',
'                                          p_http_method   => ''POST'',',
'                                          p_parm_name     => l_parm_names,',
'                                          p_parm_value    => l_parm_values);',
'',
'',
'      SELECT JSON_VALUE (l_response_clob, ''$.access_token'')',
'        INTO l_access_token',
'        FROM DUAL;',
'',
'',
'   EXCEPTION',
'      WHEN OTHERS',
'      THEN',
'         l_access_token:=NULL;',
'   END;',
'   ',
'       l_file_names := apex_util.string_to_table(v(l_filebrowse_item));',
'   -----------Upload file(s) from apex_application_temp_files',
'  for h in 1 .. l_file_names.count loop',
'   for i in (select filename,mime_type,blob_content file_blob from apex_application_temp_files where name = l_file_names(h)',
'         ) loop',
'         COMMIT;',
'   BEGIN',
'',
'   ',
'   SELECT substr(i.filename,instr(i.filename,''.'',-1,1) - length(i.filename)  ) b',
'   into l_ext',
'   from dual;',
'   if l_ext=''doc'' then',
'   l_mimetype:=''application/msword'';',
'   elsif l_ext=''xlsx'' then	',
'   l_mimetype:=''application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'';',
'   elsif l_ext=''ppt'' then	',
'   l_mimetype:=''application/vnd.ms-powerpoint'';',
'   elsif l_ext=''pdf'' then	',
'   l_mimetype:=''application/pdf'';',
'   elsif l_ext=''rtf'' then',
'   l_mimetype:=''application/rtf'';',
'   elsif l_ext=''jpe'' then	',
'   l_mimetype:=''image/jpeg'';',
'   elsif l_ext=''tif'' then',
'   l_mimetype:=''image/tiff'';',
'   elsif l_ext=''docx'' then',
'   l_mimetype:=''application/vnd.openxmlformats-officedocument.wordprocessingml.document'';',
'   elsif l_ext=''xls''  then',
'   l_mimetype:=''application/vnd.ms-excel'';',
'   elsif l_ext=''gif''  then',
'   l_mimetype:=''image/gif'';',
'   elsif l_ext=''jpeg'' then',
'   l_mimetype:=''image/jpeg'';',
'   elsif l_ext=''jpg'' then',
'   l_mimetype:=''image/jpeg'';',
'   elsif l_ext=''tiff'' then	',
'   l_mimetype:=''image/tiff'';',
'   elsif l_ext=''bmp'' then',
'   l_mimetype:=''image/bmp'';',
'   elsif l_ext=''jfif'' then',
'   l_mimetype:=''image/jfif'';',
'   elsif l_ext=''txt'' then',
'   l_mimetype:=''text/plain'';',
'   elsif l_ext=''ico'' then	',
'   l_mimetype:=''image/x-icon'';',
'   else',
'   l_mimetype:=''application/octet-stream'';',
'   end if;',
'   ',
'   ----Set headers',
'   ',
'    apex_web_service.g_request_headers.delete ();',
'	apex_web_service.g_request_headers (1).name := ''Content-Type'';',
'    apex_web_service.g_request_headers (1).value := l_mimetype;',
'    apex_web_service.g_request_headers (2).name := ''Authorization'';',
'    apex_web_service.g_request_headers (2).value := ''Bearer '' || l_access_token;',
'    apex_web_service.g_request_headers (3).name := ''Accept'';',
'    apex_web_service.g_request_headers (3).value := ''application/json'';',
'	l_rest_url:= ''https://www.googleapis.com/upload/drive/v3/files?uploadType=media'';',
'',
'  ---- Generate payload',
'       l_payload :=',
'       ''{',
'"name": "''||i.filename||''",',
'"mimeType": "''||l_mimetype||''"',
'}'';',
'      apex_json.parse(l_payload);',
'  ---- Call Web Service.',
'      l_response_clob :=',
'         apex_web_service.make_rest_request (p_url           => l_rest_url,',
'                                             p_http_method   => ''POST'',',
'                                             p_body_blob     => i.file_blob,',
'                                             p_wallet_path   => NULL,',
'                                             p_wallet_pwd    => '''');',
'',
'        commit;',
'      select JSON_VALUE(l_response_clob,',
'                  ''$.id'')',
'      into l_fileid',
'      FROM   dual;',
'',
'',
'		 ',
'		 ',
'	EXCEPTION',
'	WHEN OTHERS THEN',
'	NULL;',
'	END;',
'',
'   BEGIN',
'   l_rest_linkurl     :=''https://www.googleapis.com/drive/v2/files/''||l_fileid||''?key=''||l_api_key;',
'    apex_web_service.g_request_headers.delete ();',
'	apex_web_service.g_request_headers (1).name := ''Authorization'';',
'    apex_web_service.g_request_headers (1).value := ''Bearer '' || l_access_token;',
'    apex_web_service.g_request_headers (2).name := ''Accept'';',
'    apex_web_service.g_request_headers (2).value := ''application/json'';',
'      -- 3. Call Web Service.',
'      l_response_linkclob :=',
'         apex_web_service.make_rest_request (p_url           => l_rest_linkurl,',
'                                             p_http_method   => ''GET'',',
'                                             p_wallet_path   => NULL,',
'                                             p_wallet_pwd    => '''');',
'',
'      select JSON_VALUE(l_response_linkclob,',
'                  ''$.embedLink'')',
'      into l_preview_url',
'      FROM   dual;',
'',
'',
'   EXCEPTION',
'      WHEN OTHERS',
'      THEN',
'         return NULL;',
'         END;',
'',
'',
'         BEGIN',
'   l_parm_names (1) := ''refresh_token'';',
'   l_parm_values (1) := l_refresh_token;',
'   l_parm_names (2) := ''client_id'';',
'   l_parm_values (2) := l_client_id;',
'   l_parm_names (3) := ''client_secret'';',
'   l_parm_values (3) := l_client_secret;',
'   l_parm_names (4) := ''grant_type'';',
'   l_parm_values (4) := ''refresh_token'';',
'   l_rest_authurl := ''https://www.googleapis.com/oauth2/v4/token'';',
'   apex_web_service.g_request_headers.delete ();',
'   apex_web_service.g_request_headers (1).name := ''Content-Type'';',
'   apex_web_service.g_request_headers (1).value := ''application/x-www-form-urlencoded'';',
'   l_response_clob :=',
'      apex_web_service.make_rest_request (p_url           => l_rest_authurl,',
'                                          p_http_method   => ''POST'',',
'                                          p_parm_name     => l_parm_names,',
'                                          p_parm_value    => l_parm_values);',
'',
'',
'      SELECT JSON_VALUE (l_response_clob, ''$.access_token'')',
'        INTO l_access_token',
'        FROM DUAL;',
'',
'',
'   EXCEPTION',
'      WHEN OTHERS',
'      THEN',
'         l_access_token:=NULL;',
'   END;',
'',
'   ------------13.04.2021  set metadata',
'       BEGIN',
'   l_rest_nameurl     :=''https://www.googleapis.com/drive/v3/files/''||l_fileid||''?key=''||l_api_key;',
'       apex_web_service.g_request_headers.delete ();',
'	apex_web_service.g_request_headers (1).name := ''Content-Type'';',
'    apex_web_service.g_request_headers (1).value := ''application/json'';---l_mimetype;',
'    apex_web_service.g_request_headers (2).name := ''Authorization'';',
'    apex_web_service.g_request_headers (2).value := ''Bearer '' || l_access_token;',
'    apex_web_service.g_request_headers (3).name := ''Accept'';',
'    apex_web_service.g_request_headers (3).value := ''application/json'';',
'    ---- Generate payload',
'       l_payload :=',
'       ''{',
'"name": "''||i.filename||''",',
'"mimeType": "''||l_mimetype||''"',
'}'';',
'      apex_json.parse(l_payload);',
'      -- 3. Call Web Service.',
'      l_response_nameclob :=',
'         apex_web_service.make_rest_request (p_url           => l_rest_nameurl,',
'                                             p_http_method   => ''PATCH'',',
'                                             p_body          => l_payload,',
'                                             p_wallet_path   => NULL,',
'                                             p_wallet_pwd    => '''');',
'END;',
'',
'-------------Get permission',
'',
'',
'   BEGIN',
'   l_rest_permissionurl     :=''https://www.googleapis.com/drive/v3/files/''||l_fileid||''/permissions?key=''||l_api_key;',
'       apex_web_service.g_request_headers.delete ();',
'	apex_web_service.g_request_headers (1).name := ''Content-Type'';',
'    apex_web_service.g_request_headers (1).value := ''application/json'';---l_mimetype;',
'    apex_web_service.g_request_headers (2).name := ''Authorization'';',
'    apex_web_service.g_request_headers (2).value := ''Bearer '' || l_access_token;',
'    apex_web_service.g_request_headers (3).name := ''Accept'';',
'    apex_web_service.g_request_headers (3).value := ''application/json'';',
'    if l_email_address is not null and l_permission_type in (''user'',''group'') then',
'        l_permissionpayload :=''{',
'  "role": "''||l_permission_role||''",',
'  "type": "''||l_permission_type||''",',
'  "emailAddress": "''||l_email_address||''"',
'}'';',
'   elsif l_domain is not null and l_permission_type in (''domain'') then',
'   l_permissionpayload :=''{',
'  "role": "''||l_permission_role||''",',
'  "type": "''||l_permission_type||''",',
'  "domain": "''||l_domain||''"',
'}'';',
'else',
'      l_permissionpayload :=''{"role": "''||l_permission_role||''","type": "anyone"}'';',
'end if;',
'--"reader","anyone"',
'',
'      -- 3. Call Web Service.',
'      l_response_permissionclob :=',
'         apex_web_service.make_rest_request (p_url           => l_rest_permissionurl,',
'                                             p_http_method   => ''POST'',',
'                                             p_body          => l_permissionpayload,',
'                                             p_wallet_path   => NULL,',
'                                             p_wallet_pwd    => '''');',
'',
'    l_preview_urls:=l_preview_urls||chr(13)||chr(10)||l_preview_url;',
'    l_count:=l_count+1;',
'',
'   EXCEPTION',
'      WHEN OTHERS',
'      THEN',
'         NULL;',
'         END;',
'',
'   END LOOP;',
'END LOOP;',
' ',
' if l_preview_url is not null then',
'  --',
'apex_util.set_session_state(l_generated_urls,l_preview_urls);',
'  ',
'  --',
'  l_result.success_message:=l_count||'' File(s) successfully uploaded'';',
'  --',
'  RETURN l_result;',
'  else',
'  l_result.success_message:=''There are no files uploaded'';',
'',
'  RETURN l_result;',
'  END IF;',
'    ',
'        EXCEPTION',
'        when others then',
'         l_result.success_message:=''TAn error occurred during file upload'';',
'',
'  RETURN l_result;',
'end render;'))
,p_api_version=>2
,p_render_function=>'render'
,p_execution_function=>'render'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_version_identifier=>'1.0.2'
,p_plugin_comment=>'****Update made on the 13th April to ensure metadata is updated correctly'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(35022160623136311)
,p_plugin_id=>wwv_flow_api.id(35021698432080344)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_prompt=>'Refresh Token'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_is_translatable=>false
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(35022453679140153)
,p_plugin_id=>wwv_flow_api.id(35021698432080344)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>2
,p_display_sequence=>20
,p_prompt=>'Client ID'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_is_translatable=>false
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(35022766386142754)
,p_plugin_id=>wwv_flow_api.id(35021698432080344)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>3
,p_display_sequence=>30
,p_prompt=>'Client Secret'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_is_translatable=>false
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(35023054921146299)
,p_plugin_id=>wwv_flow_api.id(35021698432080344)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>4
,p_display_sequence=>40
,p_prompt=>'API Key'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_is_translatable=>false
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(35023320327155454)
,p_plugin_id=>wwv_flow_api.id(35021698432080344)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>5
,p_display_sequence=>50
,p_prompt=>'Permission Role'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>false
,p_default_value=>'reader'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(35023628695157519)
,p_plugin_attribute_id=>wwv_flow_api.id(35023320327155454)
,p_display_sequence=>10
,p_display_value=>'writer'
,p_return_value=>'writer'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(35024098118162709)
,p_plugin_attribute_id=>wwv_flow_api.id(35023320327155454)
,p_display_sequence=>20
,p_display_value=>'commenter'
,p_return_value=>'commenter'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(35024447213163969)
,p_plugin_attribute_id=>wwv_flow_api.id(35023320327155454)
,p_display_sequence=>30
,p_display_value=>'reader'
,p_return_value=>'reader'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(35025190004172152)
,p_plugin_id=>wwv_flow_api.id(35021698432080344)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>6
,p_display_sequence=>60
,p_prompt=>'Permission Type'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>false
,p_default_value=>'anyone'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(35025445376177403)
,p_plugin_attribute_id=>wwv_flow_api.id(35025190004172152)
,p_display_sequence=>10
,p_display_value=>'user'
,p_return_value=>'user'
,p_help_text=>'specific email address with persmission'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(35025847020179288)
,p_plugin_attribute_id=>wwv_flow_api.id(35025190004172152)
,p_display_sequence=>20
,p_display_value=>'group'
,p_return_value=>'group'
,p_help_text=>'group email addresses'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(35026251384180770)
,p_plugin_attribute_id=>wwv_flow_api.id(35025190004172152)
,p_display_sequence=>30
,p_display_value=>'domain'
,p_return_value=>'domain'
,p_help_text=>'specific domain'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(35026673808185359)
,p_plugin_attribute_id=>wwv_flow_api.id(35025190004172152)
,p_display_sequence=>40
,p_display_value=>'anyone'
,p_return_value=>'anyone'
,p_help_text=>'anyone with access to the link'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(35027263028193956)
,p_plugin_id=>wwv_flow_api.id(35021698432080344)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>7
,p_display_sequence=>70
,p_prompt=>'Email Address'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_translatable=>false
,p_help_text=>'to enter if group or user permission roles have been chosen'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(35027598280202296)
,p_plugin_id=>wwv_flow_api.id(35021698432080344)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>8
,p_display_sequence=>80
,p_prompt=>'Domain'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_translatable=>false
,p_help_text=>'enter if domain permission type has been chosen'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(35027880610206728)
,p_plugin_id=>wwv_flow_api.id(35021698432080344)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>9
,p_display_sequence=>90
,p_prompt=>'File Browse Item'
,p_attribute_type=>'PAGE ITEM'
,p_is_required=>true
,p_is_translatable=>false
,p_help_text=>'Specify File Browse Item for uploads. Ensure APEX_APPLICATION_TEMP_FILES table storage is specified.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(35028150022216931)
,p_plugin_id=>wwv_flow_api.id(35021698432080344)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>10
,p_display_sequence=>100
,p_prompt=>'Generate file links display item name'
,p_attribute_type=>'PAGE ITEM'
,p_is_required=>false
,p_is_translatable=>false
,p_help_text=>'Optional Text area or rich text editor to display links of uploaded file(s)'
);
end;
/
prompt --application/end_environment
begin
wwv_flow_api.import_end(p_auto_install_sup_obj => nvl(wwv_flow_application_install.get_auto_install_sup_obj, false));
commit;
end;
/
set verify on feedback on define on
prompt  ...done
