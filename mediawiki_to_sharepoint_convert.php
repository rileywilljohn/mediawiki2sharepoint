<?php
/*
Read an xml file created by Mediawiki's dumpBackup.php and dump out text suitable for
pasting into new Sharepoint wiki pages.
Pass the xml filename as the first argument on the command line. Text is dumped to standard output.
Example usage:  php thisscript.php mediawiki.xml > sharepoint.txt
 */
define('SEPARATOR',"\n\nж");
$doc = new DOMDocument('1.0', 'utf-8');
$doc->formatOutput = true;
$doc->preserveWhiteSpace = false;
$ret = $doc->load($argv[1]);
#print_r($ret);
$ePages = $doc->getElementsByTagName('page');
$pagecount = $ePages->length;
for ($pos=0; $pos < $pagecount; $pos++){
	$ePage = $ePages->item($pos);
	$title = $ePage->getElementsByTagName('title')->item(0)->nodeValue;
	#Only process the main namespace
	if (strpos($title,':') === false){
		$title = preg_replace('/\//m','-',$title);
		print(SEPARATOR . "\n{$title}\n<br/>\n");
		$wikitext = $ePage->getElementsByTagName('revision')->item(0)->getElementsByTagName('text')->item(0)->nodeValue;
		$newtext = $wikitext;
		#links
		$newtext = preg_replace('/(?<=\[\[).*(?=\]\])/m',"$0|$0",$newtext);
		$newtext = preg_replace('/(?:\G(?!^)|\[\[)(?:(?!\[\[|\|).)*?\K\/(?=.*\|)/m','-',$newtext);
		#h3
		$newtext = preg_replace('/(^[[:space:]]*)(={3,3})(.*)(={3,3})([[:space:]]*$)/m','<h3>\\3</h3>',$newtext);
		#h2
		$newtext = preg_replace('/(^[[:space:]]*)(={2,2})(.*)(={2,2})([[:space:]]*$)/m','<h2>\\3</h2>',$newtext);
		#h1
		$newtext = preg_replace('/(^[[:space:]]*)(={1,1})(.*)(={1,1})([[:space:]]*$)/m','<h1>\\3</h1>',$newtext);
		#table
		$newtext = preg_replace('/wikitable/m','wikitable ms-rteTable-default',$newtext);
		$newtext = preg_replace('/^\{\|(.*)$/m',"<table \\1>",$newtext);
		#table class
		$newtext = preg_replace('/^\|\}[[:space:]]*$/m',"</table>",$newtext);
		$newtext = preg_replace('/^\|-/m',"<tr>",$newtext);
		$newtext = preg_replace('/^\|[^|-]|^!/m',"<td>",$newtext);
		#ul
		$newtext = preg_replace('/(((^|\n)\*.*)+)/',"\n<ul>\\1\n</ul>\n",$newtext);
		$newtext = preg_replace('/(((^|\n)\*\*.*)+)/',"\n<li><ul>\\1\n</ul></li>\n",$newtext);
		$newtext = preg_replace('/^\*+(.*$)/m','<li>\\1</li>',$newtext);
		#ol
		$newtext = preg_replace('/(((^|\n)#.*)+)/',"\n<ol>\\1\n</ol>\n",$newtext);
		$newtext = preg_replace('/(((^|\n)##.*)+)/',"\n<li><ol>\\1\n</ol></li>\n",$newtext);
		$newtext = preg_replace('/(^#+)(.*$)/m','<li>\\2</li>',$newtext);
		#dl
		$newtext = preg_replace('/^;(.*):(.*)$/m','<dt>\\1</dt><dd>\\2</dd>',$newtext);
		$newtext = preg_replace('/(^|\n);(.*\n):(.*)/','\\1<dt>\\2</dt><dd>\\3</dd>',$newtext);
		#bold and italic
		$newtext = preg_replace('/\'{5,5}(.+)\'{5,5}/','<strong><em>\\1</em></strong>',$newtext);
		$newtext = preg_replace('/\'{3,3}(.+)\'{3,3}/','<strong>\\1</strong>',$newtext);
		$newtext = preg_replace('/\'{2,2}(.+)\'{2,2}/','<em>\\1</em>',$newtext);
		#pre
		$newtext = preg_replace('/(((^|\n) +(.+))+)/',"<pre>\\1\n</pre>",$newtext);
		#line break
		$newtext = preg_replace('/^\s*$/m',"<br/>", $newtext);
		print $newtext . "\n";
	}
}
?>