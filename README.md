Save files to Google Drive
This Oracle APEX plugin allows end users to upload files to Google Drive.

PRE-REQUISITES

Ensure you have configured REST APIs for your google drive account to retrieve refresh token,Client ID,Client secret and API Keys for use in the Plugin. 
I have attached a step by step guide (Configure Google Drive API for Gmail Users.pdf).

PLUGIN INSTALLATION

Import process type plugin (process_type_plugin_prc_kadeyemiapex_savetogoogledrive.sql) into your application and include as part of your submit page process

PLUGIN USE

On an APEX Application page: 

1. Create a File Browse page item on APEX app page and choose TABLE APEX_APPLICATION_TEMP_FILES for storage type.
2. Create a text/textarea page item on APEX app page to display generated links after successful file uploads.
3. Create page process of type plugin and select "Save file to Google Drive" Plugin.
4. Ensure the following settings information are entered:
   (a) Refresh Token (Mandatory) : available from google drive rest api configuration.
   (b) Client ID (Mandatory) : available from google drive rest api configuration.
   (c) Client Secret (Mandatory) : available from google drive rest api configuration.
   (d) API Key (Mandatory) : available from google drive rest api configuration.
   (e) Permission Role : select from available list, default role - reader 
   (f) Permission Type : select from available list, default type - anyone
   (g) Email Address (Optional) : Only if permission type user or group is selected
   (h) Domain (Optional) : Only if permission type domain is selected
   (i) File Browse Item (Mandatory): Item created in step 1
   (j) Generate file links display item name (Optional): Item created i step 2


SAMPLE APPLICATION

Install sample application f199.sql to see plugin in action
