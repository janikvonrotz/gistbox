<?php

if (isset($_COOKIE['wettbewerb20131118']) AND $_COOKIE['wettbewerb20131118']>=3) {
			echo "<p>Sie haben schon am Wettbewerb teilgenommen.</p>";
}else{

  if (isset($_GET['save']) AND $_GET['save']==true) {
	mysql_connect("localhost","wettbewerb","brewebttew"); 
	mysql_select_db("wettbewerb")
		or die(mysql_errno() ." - " . mysql_error() );
	mysql_set_charset('utf8');

	$_timestamp=date("y.m.d H:i:s");
	$_frage1=$_POST['frage1antwort1'].";".$_POST['frage1antwort2'].";".$_POST['frage1antwort3'].";".$_POST['frage1antwort4'];
	$_frage2=$_POST['frage2antwort1'].";".$_POST['frage2antwort2'].";".$_POST['frage2antwort3'].";".$_POST['frage2antwort4'].";".$_POST['frage2antwort5'];
	$_frage3=$_POST['frage3antwort1'].";".$_POST['frage3antwort2'].";".$_POST['frage3antwort3'].";".$_POST['frage3antwort4'];
	$_frage4=$_POST['frage4antwort1'].";".$_POST['frage4antwort2'].";".$_POST['frage4antwort3'].";".$_POST['frage4antwort4'];
	$_frage5=$_POST['frage5antwort1'];
	$_anrede=$_POST['anrede'];
	$_nachname=$_POST['name'];
	$_vorname=$_POST['vorname'];
	$_adresse=$_POST['adresse'];
	$_plz=$_POST['plz'];
	$_ort=$_POST['ort'];
	$_telnr=$_POST['telnr'];
	$_email=$_POST['email'];
	$_jahrgang=$_POST['jahrgang'];

// Pruefen, ob die IP nicht schon zehn mal gespeichert ist oder das Cookie den Wert 3 enthaelt
	if ($_anrede AND $_nachname AND $_vorname AND $_plz AND $_ort AND $_telnr) {
		$ipcheck = mysql_query(sprintf("SELECT id FROM wettbewerb20131118 WHERE ip='%s' GROUP BY ip HAVING COUNT(*)>=10",getenv("REMOTE_ADDR"))) or die ("Fehler: ".mysql_error());
		if ($_COOKIE['wettbewerb20131118']>=3) {
			echo "Ihre IP wurde aufgrund zu vieler Teilnahmen gesperrt";			
		} else {


// Pruefen, ob der Name in Abhaengigkeit des Alters und der Telefonnummer schon einmal vorkommt
			$namecheck = mysql_query(sprintf("SELECT id FROM wettbewerb20131118 WHERE vorname LIKE '%s' AND nachname LIKE '%s' AND tel LIKE '%%%s'",$_vorname, $_nachname,substr($_telnr,-7,7))) or die ("Fehler: ".mysql_error());
			if (mysql_num_rows($namecheck)) {
				echo "Sie haben bereits am Wettbewerb teil genommen.";
				
			} else {

				
// Cookie zur Zaehlung der Anzahl Teilnahmen setzen

				if (!isset($_COOKIE['wettbewerb20131118'])) { 
						$cookievalue = 1; 
					}else{
						$cookievalue = $_COOKIE['wettbewerb20131118'];
						$cookievalue++;
					}
					
				if (!setcookie("wettbewerb20131118",$cookievalue,time()+60*60*24*100)) {
					echo "Aktivieren Sie Cookies, um am Wettbewerb teilnehmen zu k&ouml;nnen";
				 
				} else { 

					// Daten speichern
					$_ip = $_SERVER["REMOTE_ADDR"];
					$query = sprintf("INSERT INTO wettbewerb.wettbewerb20131118
									 VALUES ('','$_timestamp','$_frage1','$_frage2','$_frage3','$_frage4','$_frage5','$_anrede','$_nachname','$_vorname','$_adresse','$_plz','$_ort','$_telnr','$_jahrgang','$_email','$_ip')");
																																																																		  
					if (mysql_query($query)) {
							echo "<link rel='stylesheet' type='text/css' href='http://www.vbl.ch/App_Themes/vbl/css/style.css'>Vielen Dank f&uuml;r Ihre Teilnahme.";
						} else {
							echo "Ihre Teilnahme konnte aufgrund eines Serverproblems nicht gespeichert werden. Probieren Sie es doch bitte sp&auml;ter noch einmal. Besten Dank f&uuml;r Ihr Verst&auml;ndnis.<br><br>";
									echo mysql_errno() . ": " . mysql_error() . "<br>" . "query = $query";
						}
				}
		
			} //end _setcookie
		}	
	} else {
		?>
        <link rel="stylesheet" type="text/css" href="http://www.vbl.ch/App_Themes/vbl/css/style.css">
        <h3>Bitte f&uuml;llen sie alle als Pflichtfelder markierten Felder aus.</h3><br \>
		<script language='javascript'>
				function goback(){
				history.back();
				}
				</script>
				<input type=button value='Zur&uuml;ck' onClick=goback()>
		<?php
		} //end checkcookie
	} else {

?>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
 <meta http-equiv="content-type" content="text/html; charset=UTF-8" /> 
<link rel="stylesheet" type="text/css" href="/typo3temp/compressor/merged-69e22bc5dce5ffd729fd40d66ec7ba77-2cad6320187d79474c7b730c1a13f2de.css.gzip?1381398068" media="all">
<link rel="stylesheet" type="text/css" href="/typo3temp/compressor/print-395b9581e087ddeea844f9dafa683c80.css.gzip?1381398068" media="print">
<link rel="stylesheet" type="text/css" href="/typo3temp/compressor/lightcase-175b6c3f2933218179f7754ecc0ea38a.css.gzip?1381398068" media="screen">
<link rel="stylesheet" type="text/css" href="/typo3temp/compressor/layout-b4c46b8232eb44c7c2e2df14e833e23f.css.gzip?1381398068" media="screen">
<link rel="stylesheet" type="text/css" href="/typo3temp/compressor/navigation-21483282e83e516d2c074cb328575b52.css.gzip?1381398068" media="screen">
<link rel="stylesheet" type="text/css" href="/typo3temp/compressor/print-1faf22a9cff2031897c25cea71775e69.css.gzip?1381398068" media="print">

<style type="text/css" >
body { margin:0; font-family: arial, helvetica, sans-serif;color: #1264a0;font-size: 12px; }
h2 { margin: 20px 0 4px 0; }
h3 { margin: 18px 0 4px 0; }
h4 { margin:0;padding:0;color: #505050;text-align: left; }
table { color:#000000;margin:10px;padding: 0; } 
</style>

<script type="text/javascript">
   function check() {
	var error=false;
	/*for (var a=1;a<=3;a++) {
		for (var b=0;b<=1;b++) { if (document.getElementsByName("frage" + a)[b].checked==true) break; }
		if (b==5) error=true;
	}*/

	if (!document.getElementsByName("anrede").value == "asdf") error=true;
	if (!document.getElementsByName("name")[0].value) error=true;
	if (!document.getElementsByName("vorname")[0].value) error=true;
	if (!document.getElementsByName("adresse")[0].value) error=true;
	if (!document.getElementsByName("plz")[0].value) error=true;
	if (!document.getElementsByName("ort")[0].value) error=true;
	if (!document.getElementsByName("telnr")[0].value) error=true;
	if (!document.getElementsById("wettbewerbsfrage")[0].value) error=true;

	alert('inhere!'+error);

	if (error==true) {
		alert('Bitte alle mit einem * markierten Felder sowie alle Wettbewerbsfragen beantworten'); 
		return false;
	}

	return true;
   }
</script>


</head>
<body> 

<form name="wettbewerbform" action="?save=true" method="post">
<h3>Wie gefällt ihnen diese vbl zeitung insgesamt?</h3>
<table>
	<tr valign="top">
		<td><input type="checkbox" name="frage1antwort1" value="Die vbl zeitung ist im Auftritt attraktiv und modern."/>Die vbl zeitung ist im Auftritt attraktiv und modern.</td>
	</tr>
	<tr height="5px"><td></td></tr>
	<tr valign="top">
		<td><input type="checkbox" name="frage1antwort2"value="Die Abstimmung von Einträgen und Bilder passen mir sehr gut."/>Die Abstimmung von Einträgen und Bilder passen mir sehr gut.</td>
    </tr>
		<tr height="5px"><td></td></tr>
	<tr valign="top">
		<td><input type="checkbox" name="frage1antwort3"value="Die zeitung ist für mich vom Auftritt her nicht zeitgemäss, eher etwas vergriffen."/>Die zeitung ist für mich vom Auftritt her nicht zeitgemäss, eher etwas vergriffen.</td>
    </tr>
		<tr height="5px"><td></td></tr>
	<tr valign="top">
		<td><input type="checkbox" name="frage1antwort4"value="Die zeitung ist für mich zu umfangreich und detailliert."/>Die zeitung ist für mich zu umfangreich und detailliert.</td>
    </tr>
</table>

<h3>Wie passt Ihnen die Themenwahl?</h3>
<table>
	<tr valign="top">
		<td><input type="checkbox" name="frage2antwort1" value="Ich werde ausreichen über Änderungen und Neuigkeiten von vbl informiert."/>Ich werde ausreichen über Änderungen und Neuigkeiten von vbl informiert.</td>
	</tr>
	<tr height="5px"><td></td></tr>
	<tr valign="top">
		<td><input type="checkbox" name="frage2antwort2"value="Die Themenwahl ist jeweils sehr abwechslungsreich."/>Die Themenwahl ist jeweils sehr abwechslungsreich.</td>
    </tr>
		<tr height="5px"><td></td></tr>
	<tr valign="top">
		<td><input type="checkbox" name="frage2antwort3"value="Mir fehlen Beiträge zu Mobilität und anderen verwandten Themen allgemein."/>Mir fehlen Beiträge zu Mobilität und anderen verwandten Themen allgemein.</td>
    </tr>
		<tr height="5px"><td></td></tr>
	<tr valign="top">
		<td><input type="checkbox" name="frage2antwort4"value="Meisten habe ich die Inhalte der Themen schon aus andren Medien erfahren."/>Meisten habe ich die Inhalte der Themen schon aus andren Medien erfahren.</td>
    </tr>
		<tr height="5px"><td></td></tr>
	<tr valign="top">
		<td><input type="checkbox" name="frage2antwort5"value="Ich würde ein Leserforum begrüssen, mich je nach dem auch aktiv daran beteiligen."/>Ich würde ein Leserforum begrüssen, mich je nach dem auch aktiv daran beteiligen.</td>
    </tr>
</table>

<h3>Erscheinungsrhytmus</h3>
<table>
	<tr valign="top">
		<td><input type="checkbox" name="frage3antwort1" value="Für mich reichen die Informationen zweimal jährlich."/>Für mich reichen die Informationen zweimal jährlich.</td>
	</tr>
	<tr height="5px"><td></td></tr>
	<tr valign="top">
		<td><input type="checkbox" name="frage3antwort2"value="Ich würde die vbl zeitung viermal jährlich bevorzugen, dafür jeweils mit weniger Inhalt."/>Ich würde die vbl zeitung viermal jährlich bevorzugen, dafür jeweils mit weniger Inhalt.</td>
    </tr>
		<tr height="5px"><td></td></tr>
	<tr valign="top">
		<td><input type="checkbox" name="frage3antwort3"value="Ich würde einen elektronischen Newsletter in regelmässigen Zeitabständen schätzen."/>Ich würde einen elektronischen Newsletter in regelmässigen Zeitabständen schätzen.</td>
    </tr>
		<tr height="5px"><td></td></tr>
	<tr valign="top">
		<td><input type="checkbox" name="frage3antwort4"value="Ich brauche keine vbl zeitung, ich erhalte diese Informationen auch aus anderen Medien."/>Ich brauche keine vbl zeitung, ich erhalte diese Informationen auch aus anderen Medien.</td>
    </tr>
</table>

<h3>News via neue Medien/Social Media/Internet/Handy</h3>
<table>
	<tr valign="top">
		<td><input type="checkbox" name="frage4antwort1" value="Ich weiss, dass vbl auch eine Facebook-Seite hat, wünsche mir auf dieser aber mehr Beiträge und Umfragen zu Mobilitätsthemen."/>Ich weiss, dass vbl auch eine Facebook-Seite hat, wünsche mir auf dieser aber mehr Beiträge und Umfragen zu Mobilitätsthemen.</td>
	</tr>
	<tr height="5px"><td></td></tr>
	<tr valign="top">
		<td><input type="checkbox" name="frage4antwort2"value="Für mich braucht vbl keine Facebook-Seite, um mit ihren Kundinnen und Kunden zu kommunizieren."/>Für mich braucht vbl keine Facebook-Seite, um mit ihren Kundinnen und Kunden zu kommunizieren.</td>
    </tr>
		<tr height="5px"><td></td></tr>
	<tr valign="top">
		<td><input type="checkbox" name="frage4antwort3"value="Wenn ich etwas über vbl wissen möchte, schaue ich auf der Website www.vbl.ch nach."/>Wenn ich etwas über vbl wissen möchte, schaue ich auf der Website www.vbl.ch nach.</td>
    </tr>
		<tr height="5px"><td></td></tr>
	<tr valign="top">
		<td><input type="checkbox" name="frage4antwort4"value="Über Fahrplanauskünfte orientiere ich mich hauptsächlich via das vbl-App auf meinem Handy."/>Über Fahrplanauskünfte orientiere ich mich hauptsächlich via das vbl-App auf meinem Handy.</td>
    </tr>
</table>

<h3>Haben Sie noch persönliche Antregungen/ Wünsche zur vbl zeitung?</h3>
<table>
	<tr valign="top">
		<td><textarea name="frage5antwort1" cols="40" rows="5" ></textarea></td>
	</tr>
</table>

<div class="conTable">
  <table cellspacing="0" cellpadding="0" border="0">
   <tbody>
   <tr>
   	<th>Registrierung</th>
   	<th>&nbsp;</th>
   </tr>
   <tr>
    <td>Anrede *</td>
    <td class="last"><input type="text" name="anrede" class="input" style="width:250px;" /></td>
   </tr>
   <tr>
    <td>Name *</td>
    <td class="last"><input type="text" name="name" class="input" style="width:250px;" /></td>
   </tr>
   <tr>
    <td>Vorname *</td>
    <td class="last"><input type="text" name="vorname" class="input" style="width:250px;" /></td>
   </tr>
   <tr>
    <td>Jahrgang</td>
    <td class="last"><input type="text" name="jahrgang" class="input" style="width:50px;" /></td>
   </tr>
   <tr>
    <td>Adresse *</td>
    <td class="last"><input type="text" name="adresse" class="input" style="width:250px;" /></td>
   </tr>
   <tr>
    <td>PLZ */ Ort *</td>
    <td class="last"><input type="text" name="plz" class="input" style="width:50px;" /> <input type="text" name="ort" class="input" style="width:196px;" /></td>
   </tr>
   <tr>
    <td>Telefonnummer *</td>
    <td class="last"><input type="text" name="telnr" class="input" style="width:250px;" /></td>
   </tr>
   <tr>
    <td>E-Mail</td>
    <td class="last"><input type="text" name="email" class="input" style="width:250px;" /></td>
   </tr>
   <tr>
    <td>&nbsp;</td>
    <td class="last"><input type="submit" class="input" value="senden" target="_top" /></td>
    </tbody>
  </table>
</div>
</form>

 <br />
<?php }
}?>

</body>
</html>
