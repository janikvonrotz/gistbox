# My Parkour Luzern

Domain: my.parkourluzern.ch

# Ziel

* Erfassen von Trainingsdaten
* Self-Site für Parkour-Luzern Mitglieder
* Export der Mitglieder für Mail News Letter und Rechnungen


# Anforderungen

* Bestimmte Mitglieder können Trainings und Teilnehmer erfassen (Administratoren)
* Mitglieder können sich selbständig registrieren und persönliche Daten verwalten
* Es lassen sich Auswertungen erstellen 


# Daten

* Trainings
  * Datum
  * Type: "Geleitet";"Frei"
* Teilnehmer
  * ID Training
  * ID Teilnehmer
* Mitglieder
  * Geschlecht
  * Vorname
  * Nachnahme
  * Adresse
    * Strasse
    * PLZ / Ort
  * E-Mail
  * Passwort
  * Mitgliedschaft: "Aktiv";"Passiv"
  * Bezahlmodell: "Täglich";"Monatlich";"Jährlich"
  * Newsletter: "Ja";"Nein"


# Software

* https://www.meteor.com/
* Warum?
  * Real-Time
  * JavaScript  / Node (This is da future shit)
  * Easy to learn > https://www.discovermeteor.com/
  * Predefined modules
    * Accounts: http://docs.meteor.com/#accounts_api
* https://github.com/jsdelivr/jsdelivr
  * Bootstrap
  * jQuery
  * Modernizr
  * List.js
* Amazon AWS Hosting
  * Sponsored by Janik von Rotz


# Namespacing, Routing, Logic

## /
Root

* List links for Administrators
  * /Trainings
  * /Me
  * /Export
* Redirect normal users to /Me

## /Training
List of Trainings

* List of Trainings
* Add new Trainings

## /Training/[ID]
Detail Ansicht eins Trainings

* Teilnehmer erfassen
* Trainings Daten bearbeiten

## /Me
Settings
Trainings Attended 
		
		
## /Export
CSV Exports

* Mitglieder und Trainings
* Mitglideder E-Mail


# Views

## /

* Einfache Seite

## /Training

* Liste bearbeiten mit durchsuchen, sortieren mit List.js
	
## /Training/[ID]

* Einfaches Formular
* Teilnehmer Liste mit List.js 
	
## /Me

* Einfaches Formular
* Liste mit besuchten Trainings mit List.js
	
## /Export

* Einfache Seite
	
