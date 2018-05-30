{\rtf1\ansi\ansicpg1252\cocoartf1348\cocoasubrtf170
{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
\margl1440\margr1440\vieww10800\viewh8400\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural

\f0\fs24 \cf0       <javascript>\
         <jsitem location="inlinesnippet" name="EditMode" cachelocation="false">var $ = skuid.$;\
\
// check for "global" toggle state variable\
// if it doesn't exist, create it\
\
\
if(!window.blEditorMode) window.blEditorMode = 'read';\
\
// this will grab any visible field editor\
\
var fieldeditors = $('.nx-basicfieldeditor');\
\
if(window.blEditorMode == 'read') \{\
\
    // toggle button text / icon\
    $('.ui-button:visible').has('.ui-silk-pencil').each(function() \{\
        $(this).find('.ui-button-text').text('Read Mode');            \
        $(this).find('.ui-icon').removeClass('ui-silk-pencil')\
            .addClass('ui-silk-book-open');\
    \});\
\
\
    // find all field editors and switch their mode\
    \
    fieldeditors.each(function()\{\
\
        // get field editor's js component\
        \
        var fieldeditor = $(this).data('object');  \
        fieldeditor.mode = 'edit';\
        fieldeditor.list.render(\{doNotCache:true\});         \
    \});\
\
    window.blEditorMode = 'edit';\
\
\} else \{\
\
    // toggle button text / icon\
\
    $('.ui-button:visible').has('.ui-silk-book-open').each(function() \{\
        $(this).find('.ui-button-text').text('Edit Mode');            \
        $(this).find('.ui-icon').removeClass('ui-silk-book-open')\
            .addClass('ui-silk-pencil');\
\
    \});\
\
    fieldeditors.each(function()\{\
\
        // get field editor's js component        \
\
        var fieldeditor = $(this).data('object');  \
        fieldeditor.mode = 'read';\
        fieldeditor.list.render(\{doNotCache:true\});         \
\
    \});\
\
    window.blEditorMode = 'read';\
\}</jsitem>\
         <jsitem location="inlinesnippet" name="DefineWhoId" cachelocation="false">// Define the possible target objects\
\
\
var targetObjects = ['Contact'];\
\
// Render as a Picklist instead of an Autocomplete?\
\
var renderAsPicklist = false;\
var field = arguments[0],\
\
    value = skuid.utils.decodeHTML(arguments[1]),\
    metadata = field.metadata,\
    $ = skuid.$;\
\
\
if (field.mode == 'edit') \{\
    // Limit the set of target objects\
\
    var targets = [],\
        uniqueTargets = \{\};\
\
    $.each(metadata.referenceTo,function(i,r)\{\
\
        if (($.inArray(r.objectName,targetObjects) != -1)\
        &amp;&amp; (!uniqueTargets[r.objectName])) \{\
            targets.push(r);\
            uniqueTargets[r.objectName] = 1;\
            if (targets.length == targetObjects.length) return false;\
\
        \}\
    \});\
\
\
    if (targets.length) \{\
\
        // Make this field render as a picklist?\
        if (renderAsPicklist) field.options.type = 'REFPICK';\
        // Override the current referenceTo\
        metadata.referenceTo.length = 0;\
        var ref = [];\
        $.each(targets,function()\{\
        	ref.push(this.objectName);\
        \});\
\
        metadata.ref = ref.join();\
        metadata.referenceTo = targets;\
    \}\
\}\
\
// Run the standard renderer\
\
skuid.ui.fieldRenderers[metadata.displaytype][field.mode](field,value);</jsitem>\
         <jsitem location="inlinesnippet" name="RealTimeRenderer" cachelocation="false">var FIELDS_TO_LISTEN_ON = ['Nurse_Intake_Time_Patient_Time_Zone__c'];	\
var field = arguments[0],\
   value = arguments[1],\
   row = field.row,\
   listener;\
\
skuid.ui.fieldRenderers.DATETIME[field.mode](field,value);\
\
// Register a listener so that if any of FIELDS_TO_LISTEN_ON are updated,\
// then we will update ourself as well.\
\
if (!listener) \{\
   \
   listener = new skuid.ui.Field(row,field.model,null,\{register:false\});\
\
   var calcNewValue = function()\{\
\
       var  value0 = row.Nurse_Intake_Time_Patient_Time_Zone__c || 0,\
            value1 = skuid.time.parseSFDateTime(value0),\
            value2 = row.Nurse_Assignment__r.UTC_Offset__c || 0,\
            value3 = row.Account.tz__UTF_Offset__c || 0,        \
        \
        newValue0 = value1 + (value2/24 - value3/24);\
        newValue=skuid.time.getSFDateTime(newValue0);\
       \
       field.model.updateRow(row,'Nurse_Intake_Time_Patient_Time_Zone__c',newValue);\
\
       field.element.empty();\
       skuid.ui.fieldRenderers.DATETIME.readonly(field,newValue);\
       \
   \}\
   \
    listener.handleChange = function()\{calcNewValue (); \};\
    listener.render = function() \{\};\
\
   skuid.$.each(FIELDS_TO_LISTEN_ON,function(i,fieldToRegisterOn)\{\
       field.model.registerField(listener,fieldToRegisterOn);\
   \});\
\
   setTimeout(function()\{\
       // If there is already a changes row for this item,\
       // then run calculation\
       if (field.model.changes[field.row.Id]) \{\
             calcNewValue ();\
       \}\
   \},100);\
\
\
\}</jsitem>\
         <jsitem location="inlinesnippet" name="LookupUser" cachelocation="false">// Define the possible target objects\
\
\
var targetObjects = ['User'];\
\
// Render as a Picklist instead of an Autocomplete?\
\
var renderAsPicklist = false;\
var field = arguments[0],\
\
    value = skuid.utils.decodeHTML(arguments[1]),\
    metadata = field.metadata,\
    $ = skuid.$;\
\
\
if (field.mode == 'edit') \{\
    // Limit the set of target objects\
\
    var targets = [],\
        uniqueTargets = \{\};\
\
    $.each(metadata.referenceTo,function(i,r)\{\
\
        if (($.inArray(r.objectName,targetObjects) != -1)\
        &amp;&amp; (!uniqueTargets[r.objectName])) \{\
            targets.push(r);\
            uniqueTargets[r.objectName] = 1;\
            if (targets.length == targetObjects.length) return false;\
\
        \}\
    \});\
\
\
    if (targets.length) \{\
\
        // Make this field render as a picklist?\
        if (renderAsPicklist) field.options.type = 'REFPICK';\
        // Override the current referenceTo\
        metadata.referenceTo.length = 0;\
        var ref = [];\
        $.each(targets,function()\{\
        	ref.push(this.objectName);\
        \});\
\
        metadata.ref = ref.join();\
        metadata.referenceTo = targets;\
    \}\
\}\
\
// Run the standard renderer\
\
skuid.ui.fieldRenderers[metadata.displaytype][field.mode](field,value);</jsitem>\
         <jsitem location="inlinesnippet" name="OverdueTask" cachelocation="false">$ = skuid.$;\
\
var field = arguments[0];\
value = skuid.utils.decodeHTML(arguments[1]); \
\
skuid.ui.fieldRenderers[field.metadata.displaytype][field.mode](field,value); \
var taskStatus = field.model.getFieldValue(field.row,'IsClosed'); \
\
    if (value &lt; skuid.time.getSFDateTime(new Date()) &amp;&amp; taskStatus === false ) \{ \
    field.element.css(\{'background-color':'red','color':'white'\}); \
    \} </jsitem>\
         <jsitem location="inlinesnippet" name="Back" cachelocation="false">var params = arguments[0],\
	$ = skuid.$;\
	\
	window.history.back();\
</jsitem>\
         <jsitem location="inlinesnippet" name="KeyTasks" cachelocation="false">$ = skuid.$;\
var field = arguments[0],\
    value = arguments[1];\
\
skuid.ui.fieldRenderers[field.metadata.displaytype][field.mode](field,value); \
\
if (value  === 'Completed' || value === 'Not Required') \{ \
        field.item.element.addClass("highlighted-row");\
    \}</jsitem>\
         <jsitem location="inlinesnippet" name="CreateBookletConsultationMedRec" cachelocation="false">var params = arguments[0];\
var $ = skuid.$;\
var records = skuid.$.map(arguments[0].list.getSelectedItems(),function(item)\{ \
    return item.row.Id; \
    \});\
\
var models = skuid.model.map();\
var cases = models.AllConsultationCases;\
var medrec = models.NewBooklet;\
var consultationmedrecs = models.BookletConsultationMedRecs;\
\
\
medrec.save(\{callback:function()\{\
    var Id = medrec.getFieldValue(medrec.getFirstRow(),'Id');\
    for(var n in records)\{\
        var row = cases.getRowById(records[n]);\
            console.log('Row: ' + row);\
            console.log('Row Id: ' + row.Id);\
        if(row !== false)\{\
            var newRow = consultationmedrecs.createRow(\{\
                additionalConditions: [\
                    \{ field: 'MedRec__c', value: Id \},\
                    \{ field: 'Case__c', value: row.Id \},\
                ]\
            \});\
            \}\
    \}\
    \
    consultationmedrecs.save();\
\
\}\});</jsitem>\
         <jsitem location="inlinesnippet" name="AddMoreBookletConsultationMedRecs" cachelocation="false">var params = arguments[0];\
var $ = skuid.$;\
var records = skuid.$.map(arguments[0].list.getSelectedItems(),function(item)\{ \
    return item.row.Id; \
    \});\
\
var models = skuid.model.map();\
var cases = models.AllConsultationCases;\
var medrec = models.CurrentMedRec;\
var consultationmedrecs = models.BookletConsultationMedRecs;\
\
\
medrec.save(\{callback:function()\{\
    var Id = medrec.getFieldValue(medrec.getFirstRow(),'Id');\
    for(var n in records)\{\
        var row = cases.getRowById(records[n]);\
            console.log('Row: ' + row);\
            console.log('Row Id: ' + row.Id);\
        if(row !== false)\{\
            var newRow = consultationmedrecs.createRow(\{\
                additionalConditions: [\
                    \{ field: 'MedRec__c', value: Id \},\
                    \{ field: 'Case__c', value: row.Id \},\
                ]\
            \});\
            \}\
    \}\
    \
    consultationmedrecs.save();\
\
\}\});</jsitem>\
         <jsitem location="inlinesnippet" name="BookletHOLD" cachelocation="false">var field = arguments[0],    \
    value = arguments[1],\
    $ = skuid.$;\
    \
if(field.metadata.accessible)\{\
    if( value === true )\{\
        field.element.css(\{'background-color':'red'\});\
    \}\
    \
    skuid.ui.fieldRenderers[field.metadata.displaytype][field.mode](field,value);\
\} \
    </jsitem>\
         <jsitem location="inlinesnippet" name="SaveConsLookforClose" cachelocation="false">var openConsultationCount = skuid.model.getModel('OtherConsultations').data.length,\
    HospitalCase = skuid.model.getModel('ThisHospitalCase'),\
    theHospCase = HospitalCase.getFirstRow();\
\
//set your shortcuts and initial variables.\
returnVal = true;\
$ = skuid.$;\
\
//get the values of the fields you're interested in:\
    var HospStatus = HospitalCase.getFieldValue(theHospCase, 'IsClosed');\
\
//Create your conditional statements\
if (HospStatus !== true &amp;&amp; openConsultationCount === 0)  \{\
returnVal = false;\
\}\
return returnVal;</jsitem>\
         <jsitem location="inlinesnippet" name="saveBkltLookForClose" cachelocation="false">var     PatientCase = skuid.$M('PatientCaseTheCase'),\
        thePatientCase = PatientCase.getFirstRow();\
        openHospitalCaseCount = skuid.model.getModel('OpenHospitalCases').data.length,\
        openConsultationCount = skuid.model.getModel('OtherConsultations').data.length,\
        openBookletCount = skuid.model.getModel('OpenBooklets').data.length;\
        openTaskCount = skuid.model.getModel('OpenKeyTasks').data.length,\
\
\
//set your shortcuts and initial variables.\
returnVal = true;\
$ = skuid.$;\
\
var    PtCaseClosed = PatientCase.getFieldValue(thePatientCase, 'IsClosed');\
\
\
//Create your conditional statements\
if ( openTaskCount !== 0 || (openBookletCount === 1 &amp;&amp; openConsultationCount === 0 &amp;&amp; ( PtCaseClosed === false || openHospitalCaseCount !== 0) ) )  \{\
    returnVal = false;\
\}\
\
return returnVal;</jsitem>\
         <jsitem location="inlinesnippet" name="saveHospLookForClose" cachelocation="false">var     PatientCase = skuid.$M('PatientCaseTheCase'),\
        thePatientCase = PatientCase.getFirstRow();\
        openHospitalCaseCount = skuid.model.getModel('OpenHospitalCases').data.length,\
        openConsultationCount = skuid.model.getModel('OtherConsultations').data.length,\
        BookletCount = skuid.model.getModel('Booklets').data.length;\
        openBookletCount = skuid.model.getModel('OpenBooklets').data.length;\
\
//set your shortcuts and initial variables.\
returnVal = true;\
$ = skuid.$;\
\
var    PtCaseClosed = PatientCase.getFieldValue(thePatientCase, 'IsClosed');\
\
//Create your conditional statements\
if ( openConsultationCount !== 0 || BookletCount === 0 || \
    (PtCaseClosed === false &amp;&amp; openHospitalCaseCount === 1 &amp;&amp; openBookletCount === 0 &amp;&amp; BookletCount !== 0 ) )  \{\
    returnVal = false;\
\}\
\
return returnVal;</jsitem>\
         <jsitem location="inlinesnippet" name="savePatientCaseLookForClose" cachelocation="false">var     PatientCase = skuid.$M('PatientCaseTheCase'),\
        thePatientCase = PatientCase.getFirstRow();\
        openHospitalCaseCount = skuid.model.getModel('OpenHospitalCases').data.length,\
        openConsultationCount = skuid.model.getModel('OtherConsultations').data.length,\
        openBookletCount = skuid.model.getModel('OpenBooklets').data.length;\
\
//set your shortcuts and initial variables.\
returnVal = true;\
$ = skuid.$;\
\
var    PtCaseClosed = PatientCase.getFieldValue(thePatientCase, 'IsClosed');\
\
//Create your conditional statements\
if ( openConsultationCount !== 0 || openBookletCount !== 0  || openHospitalCaseCount !== 0 )  \{\
    returnVal = false;\
\}\
\
return returnVal;</jsitem>\
         <jsitem location="inlinesnippet" name="BkltKeyTasks" cachelocation="false">var     Booklet = skuid.$M('CurrentMedRec'),\
        theBooklet = Booklet.getFirstRow();\
        openTaskCount = skuid.model.getModel('OpenKeyTasks').data.length,\
\
returnVal = true;\
$ = skuid.$;\
\
var    BookletStatus = Booklet.getFieldValue(theBooklet, 'Status__c');\
\
//Open Task Count should be 1 - just "Booklet Sent" task.\
\
if ( openTaskCount === 1 &amp;&amp; (BookletStatus === 'In Process' || BookletStatus === 'New') )  \{\
    returnVal = false;\
\}\
\
return returnVal;</jsitem>\
         <jsitem location="inlinesnippet" name="highPriorityRenderer" cachelocation="false">var $ = skuid.$,\
    field = arguments[0],\
    value = arguments[1];\
    \
if( value == 'Emergency - Same Day' || value == 'Emergency - 24 hr') \{ \
\
var cellElem = field.element;\
var iconElem =\
    $( '&lt;div&gt;' ) // create the icon container\
        .addClass('ui-silk') // mark the container as a silk icon container\
        .appendTo( cellElem ); // add the container to the cell\
\
    switch( value )\{\
        case 'Emergency - Same Day':\
            // apply the red flag icon to the container\
            iconElem.addClass('ui-silk-flag-red');\
            break;\
        case 'Emergency - 24 hr':\
            // apply the orange flag icon to the container\
            iconElem.addClass('ui-silk-flag-orange');\
            break;\
    \}\
    \
\} else \{\
        skuid.ui.fieldRenderers.STRING.read(field,'');\
    \
\}</jsitem>\
         <jsitem location="inlinesnippet" name="CreatePackage" cachelocation="false">var params = arguments[0],	\
$ = skuid.$;\
\
var models = skuid.model.map();\
var theCase = models.CurrentConsForReport.getFirstRow();\
\
\
var url = 'https://composer.congamerge.com' +\
'?sessionId=' + skuid.utils.userInfo.sessionId + \
'&amp;serverUrl=' + sforce.connection.partnerServerUrl +\
'&amp;id=' + theCase.Id +\
'&amp;QVar0ID=a0GE000000TL60S' +\
'&amp;templateid=' + theCase.Consultation_Request_Query_Template_ID__c + ',\{QVar0\}' +\
'&amp;OFN=' + theCase.Consultation_Request_Subject__c +\
'&amp;QueryId=[PathConsultMedRecs]a0GE000000WIOb6?pv0=' + theCase.Id + ',' +\
'[RadConsultMedRecs]a0GE000000WIOi1?pv0=' + theCase.Id + ',' +\
'[RefConsultMedRecs]a0GE000000WIOi6?pv0=' + theCase.Id + ',' +\
'[History]a0GE000000WIOiG?pv0=' + theCase.Id + ',' +\
'[Reports]a0GE000000WIOiL?pv0=' + theCase.Id + ',' +\
'&amp;DefaultPDF=1' +\
'&amp;QVar0Format=10010' +\
'&amp;SC0=1' +\
'&amp;OCNR=1' +\
'&amp;UF0=1' +\
'&amp;DS7=5' +\
'&amp;BML=One+moment!++Generating+your+' + theCase.Type + '+form';\
\
window.open(url, '_blank', 'height=600, width=884');</jsitem>\
         <jsitem location="inlinesnippet" name="CancelPatientCase" cachelocation="false">var     PatientCase = skuid.$M('PatientCaseTheCase'),\
        thePatientCase = PatientCase.getFirstRow(),\
        openCaseCount = skuid.model.getModel('CasesToCancelHold_Patient').data.length,\
        openBookletCount = skuid.model.getModel('OpenBooklets').data.length;\
\
//set your shortcuts and initial variables.\
returnVal = true;\
$ = skuid.$;\
\
var    ptstatus = PatientCase.getFieldValue(thePatientCase, 'Status');\
\
//Create your conditional statements\
if ( ( ptstatus === "Cancelled" ||  ptstatus === "On Hold" ) &amp;&amp; ( openCaseCount !== 0 || openBookletCount !== 0 ) )  \{\
    returnVal = false;\
\}\
\
return returnVal;</jsitem>\
         <jsitem location="inlinesnippet" name="CancelHospitalCase" cachelocation="false">var     HospCase = skuid.$M('ThisHospitalCase'),\
        theHospCase = HospCase.getFirstRow(),\
        openConsultationCount = skuid.model.getModel('OtherConsultations').data.length;\
\
//set your shortcuts and initial variables.\
returnVal = true;\
$ = skuid.$;\
\
var    HospStatus = HospCase.getFieldValue(theHospCase, 'Status');\
\
//Create your conditional statements\
if ( ( HospStatus === 'Cancelled' || HospStatus === 'On Hold' || HospStatus === 'Deleted' ) &amp;&amp; openConsultationCount !== 0 )  \{\
    returnVal = false;\
\}\
\
return returnVal;</jsitem>\
         <jsitem location="inlinesnippet" name="ReportIsReadOnly" cachelocation="false">var $ = skuid.$,\
    field = arguments[0],\
    value = arguments[1];\
\
skuid.ui.fieldRenderers[field.metadata.displaytype][field.mode](field,value);\
\
var medRecType = field.model.getFieldValue(field.row,'Type__c');\
\
    if (medRecType === 'TRC Report' || medRecType === 'TPC Report' || medRecType === 'PMC Report' ) \{\
\
        skuid.ui.fieldRenderers.STRING.read( field, value );\
\
    \}\
</jsitem>\
         <jsitem location="inlinesnippet" name="LookForDP" cachelocation="false">var     PatientCase = skuid.$M('PatientCaseTheCase'),\
        thePatientCase = PatientCase.getFirstRow(),\
\
//set your shortcuts and initial variables.\
returnVal = true;\
$ = skuid.$;\
\
var    DPRcvd = PatientCase.getFieldValue(thePatientCase, 'Designated_Physician__c');\
\
//Create your conditional statements\
if ( DPRcvd === null )  \{\
    returnVal = false;\
\}\
\
return returnVal;</jsitem>\
      </javascript>}