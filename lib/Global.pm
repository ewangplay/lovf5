package Global;
require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(
	MessageBox 
	FileSetContents
	);

use strict;
use Crypt::Blowfish;

# MessageBox(
# 	parent_window,
# 	message_type,	#info, warning, question, error
# 	message);
sub MessageBox {
	my ($parent, $type, $message) = @_;
	my $dlg_msg;
	$dlg_msg = Gtk2::MessageDialog->new($parent,
		'destroy-with-parent',
		$type,
		'ok',
		$message);
	$dlg_msg->run;
	$dlg_msg->destroy;
}

sub FileSetContents {
        my ($filename, $contents) = @_;
        open FILE_HANDLE, ">$filename" || die("set file $filename contents failed.\n");
        print FILE_HANDLE ($contents);
        close FILE_HANDLE;
}

1; #terminate this package with 1
