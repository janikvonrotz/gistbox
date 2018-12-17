# Introduction

This walkthrough shows how to build an automated registration form that closes down registration if the seats in the class fill up.

# Create Lists

This solution requires two lists, one containing the classes and another one containing the registrations.

## Class Calendar

The class calendar list holds the classes and informations such as the remaining seats.

Type: Calendar 

Fields:

* Seats
  * Type: Number

* FilledSeats
  * Type: Number

* RemainingSeats
  * Type: Calculated
  * Formula: `=Seats-FilledSeats`
  * Data type returned: Number
  
* SeatsIncrement
  * Type: Calculated
  * Formula: `=FilledSeats+1`
  * Data type returned: Number
  
* Closed
  * Type: Yes/No
  * Default value: No
  
* StaticID
  * Type: Number
  * Note: This is a Hack we have to put in because we can’t use the real ID field in a calculated column. We will use a workflow to fill it in correctly later. I am open to suggestions on a better way to do this.
  
* Register
  * Type: Calculated
  * Formula: `=IF(Closed=TRUE;"Closed for registration";IF(RemainingSeats>0;CONCATENATE("<a href='#' onclick='OpenRegistrationForm(";StaticID;")'>Register</a>");"Class is Full"))`
  * Data type returned: Number
  * Note: You might have to replace the semicolons with commas as this seperater depends on the SharePoint localized installation.
  
### Class Calendar view

In order to register for an class we need a custom view.

Type: Default view

Option: Make this the default view

Columns:

* Title
* Location
* Description
* Start Time
* End Time
* Seats
* RemainingSeats
* Register

## Class Attendees

This list contains the registration every entry shows the attendee and the chosen class ID.

Type:  Custom List 

Fields:

* Username
  * Type: Single line of text
  * Option: Required
  
* Meeting
  * Type: Lookup
  * List: Class Calendar
  * Field: Title
  
* MeetingID
  * Type: Single line of text

# Create Workflows

## SetStaticClassID Workflow

The SetStaticClassID Workflow is really a hack because SharePoint won’t let you use the ID field in the calculated columns. All we are doing is setting a number field with the ID field every time the calendar item is created or modified. 

1.	Open the Class Calendar in SharePoint Designer
2.	Add a list workflow
3.	Name it: SetStaticClassID
4.	Update Start Options: Start Workflow automatically when an item is created and Start workflow automatically when an item is changed
5.	Add an action: Set Field in Current Item
6.	For field link choose: StaticID 
7.	For value link click on the fx button
8.	Data source: Current Item
9.	Field from source: ID
10.	Save and publish

## Registration Workflow

The Registration Workflow is one of the main parts of this solution. This is the Workflow that will update the remaining seats in the calendar list when an Attendee register for the course.

1.	Open the Class Attendees list in SharePoint Designer
2.	Add a list workflow
3.	Name it: Registration
4.	Update Start Options: Start Workflow automatically when an item is created
5.	Add an action: Update List Item
6.	Click the "this list" link in the action
7.	Change the list ot the Class Calendar list created earlier
8.	Click the "Add" button
9.	Choose "FilledSeats"
10.	Click the fx button
11.	Data source: Class Calendar
12.	Fiel from source: SeatIncrement
13.	Field: ID
14.	Click the fx button
15.	Data source: Current Item
16.	Fiel from source: Meeting
17.	Close all dialogs until you get back to the "Update list Item" dialog by clicking on ok
18.	In the same dialog in the Find the list item section choose for Field: ID
19.	Click on the fx button
20.	Data source: Current Item
21.	Field from source: Meeting
22.	Click ok
23.	Save and publish

# Create InfoPath Form

The end user will eventually register through the InfoPath form on the Class Attendees list.

1.	Open the Class Attendees list InfoPath form
2.	Right-click on the Title entry field and select Text Box Properites
3.	Click the fx button on the default value filed
4.	Add this for the formula `concat(Username, " registration for event number ", Meeting)`
5.	Add a fomratting rule to the Title and MeetingID field
6.	Check "Hide this control" foreach formatting rule
7.	Move the filed Title and MeetingID to the bottom of the form as the will be invisible.
8.	Add a formatting rule to the Username and Meeting field
9.	Check "Disable this control" foreach formatting rule
10.	Right-click on the Username entry field and select Text Box Properites
11.	Click on the fx button for the default value
12.	Add this formula `username()`
13.	10.	Select the Meeting entry field
14.	11.	In the Properties tab click the "Default Value" button
15.	Click the fx button on the default value field
16.	Insert the MeetingID field
17.	Delte the Attachments field
18.	Publish the form

# Querystring

In order to automatically set the the meeting in the InfoPath form, we will use a query string to the MeetingID field.

1. Open the Class Attendees list
2. Select the List tab > Form Web Parts > (Item) New Form
3. Add a Query String (URL) Filter webpart
4. Updat the "Query String Parameter Name" with meeting_id in the webpart properties
4. In the webpart options select Connection > Send Filter Values To > InfoPath Form Web Part
5. Select the MeetingID field as Consumer Field Name
6. Save the changes

# Add JavaScript

The javascript creates the dialog box javascript to open our new form. The call to this javascript method is in the calculated field on the attendees list to register.

1. Open the SharePoint site were you are going to display the Class Calendar list webpart
2. Edit the page and select Embed Code on the Insert tab
3. Paste the following javascript and save the page

```javascript
<script type="text/javascript" src="//cdn.jsdelivr.net/jquery/2.1.0/jquery.min.js">
// visit http://www.jsdelivr.com/#!jquery to update the cdn url
</script>
<script type="text/javascript">
function OpenRegistrationForm(meeting_id){
    var options = {
    // to geht following make a right click on the new item link in the Class Attendees list and select open in new tab.
    // Now copy the url in the browser from the beginning to the of the &RootFolder= part
    // Inser the link below and replace [RootFolder] with meeting_id
    url:"http://sharepoint.vbl.ch/Personal/Lists/Class%20Attendees/Item/newifs.aspx?List=21803ee2-66ab-4df2-9116-b02853ca7e1a&meeting_id="  + meeting_id,
    width: 750,
    height: 600,
    dialogReturnValueCallback: DialogCallback
  };
  SP.UI.ModalDialog.showModalDialog(options);
}
function DialogCallback(dialogResult, returnValue){}
</script>
```

# Finally

Now we got everything required to set up our Class Registration Form.

1. Open the SharePoint site were you are going to display the Class Calendar list webpart
2. Add the Class Calendar list webpart
3. Edit the webpart and select the Registration view
4. Add a class example
4. Now you should be able to register for classes by click on the registration link.

# Source

[SharePoint Calculated Columns By Andy Wessendorf](http://sharepoint.rackspace.com/calculated-columns-tutorial)
[SharePoint 2010 Class Registration Form](http://www.greggalipeau.com/2012/05/20/sharepoint-2010-class-registration-form/)
[Enable clickable urls in calculated fiels](http://sharepointjavascript.wordpress.com/2009/10/15/reformat-url-from-calculated-column-with-decent-clickable-link-text/))