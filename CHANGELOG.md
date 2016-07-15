# Change Log
All notable diversions from the original redmine api will be documented in this file.

## [Unreleased]
### Added
- authenticate with imperator_api_key
- actions :create, :update and :destroy for the roles controller

*Keep nice formatting based on http://keepachangelog.com/.*

## [Timelog API]

#CREATE
POST '/imperator_api/v1/time_entries.json'
Creates a time entry.
Parameters:
    time_entry (required): a hash of the time entry attributes, including:
        spent_on: the date the time was spent (default to the current date)
        hours (required): the number of spent hours
        activity_id: the id of the time activity. This parameter is required unless a default activity is defined in Redmine.
        comments: short description for the entry (255 characters max)

Response:
    201 Created: time entry was created
    422 Unprocessable Entity: time entry was not created due to validation failures (response body contains the error messages)
Changes made to original method:
# project_id is always set to Project.where(name: "Nieświadczenie usług").first!
# issue_id is always set to ''
# different 'not authorized' response

#UPDATE 
PUT /imperator_api/v1/time_entries/:id.json
Updates the time entry of given id.
Parameters:
    time_entry (required): a hash of the time entry attributes 
Response:
    200 OK: time entry was updated
    422 Unprocessable Entity: time entry was not updated due to validation failures (response body contains the error messages)

#UPDATE BULK
POST /imperator_api/v1/time_entries/bulk_update.json
Updates multiple entries at once.
Parameters: 
  ids (required): an array of ids
  time_entry (required): a hash of the time entry attributes
Response:
    200 OK: time entry was updated
    422 Unprocessable Entity: time entry was not updated due to validation failures (response body contains the error messages)
Changes made to original method:
# modified @time_entries set in 'find time entries' before filter

#DELETE
/imperator_api/v1/time_entries/:id.json'
Deletes the time entry of given id.
Response:
    200 OK: deletion successful
    422 Unprocessable Entity: time entry not deleted
Changes made to original method:
# modified @time_entries set in 'find time entries' before filter


