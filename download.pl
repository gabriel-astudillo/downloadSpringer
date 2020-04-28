#!/usr/bin/env perl

#
# Probado en Linux Debian con:
#  GNU bash, version 4.4
#  Perl 5, version 26, 
#  curl 7.58.0 
#
# Uso:
# 	En un archivo (books.csv) almacenar los
#   nombres y su enlace a springer, separados
#   por ';'
#   Verificar que los nombres no contengan caracteres extraños:
#    apóstrofes, tildes, etc

use strict;


open FILE, "books.csv";
my @archivo =  <FILE>;
close FILE;

my @downloadLinks;

`mkdir -p downloads`;

my $lines;
foreach $lines (@archivo){
	print "=======\n";
	my $output;
	my $res;
	chop($lines);
	
	my @fields = split(";", $lines);
	
	print "Libro: " . $fields[0]. "\n";
	
	my $outputHtmlFile = "$fields[0].txt";
	my $outputPdfFile = "$fields[0].pdf";
	
	my $cmd = "curl -Ls \"". $fields[1] ."\" -o $outputHtmlFile"; 
	`$cmd`;
	
	$cmd = "cat $outputHtmlFile | grep 'Download this book' | head -1 ";
	
	$output = `$cmd`;
	
	my $link;
	$output =~ /.*<a href="(.*pdf)".*target=.*>/;
	$link = $1;
	
	$link = "https://link.springer.com". $1;
	
	print "Download Link: $link\n";
	push @downloadLinks, "$fields[0];$link";
	$cmd = "curl -s \"$link\" -o downloads/$outputPdfFile";
	$res = system($cmd);
	
	if($res != 0){
		print "Error: ==> Could not download: $link <==";
	}
	else{
		print "Book saved in: ./downloads/$outputPdfFile\n";
	}
	
	$cmd = "rm $outputHtmlFile";
	`$cmd`;
	
}

# Descomentar lo siguiente si desea un
# listado de los links de descarga directos

#print "\n\n===DOWNLOAD LINKS===\n";
#
#foreach (@downloadLinks){
#	print "$_\n";	
#}