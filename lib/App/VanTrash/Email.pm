package App::VanTrash::Email;
use Moose;
use Email::Send;
use Email::MIME;
use Email::MIME::Creator;
use App::VanTrash::Template;

has 'base_path' => (is => 'ro', isa => 'Str',    required   => 1);
has 'mailer'    => (is => 'ro', isa => 'Object', lazy_build => 1);
has 'template' => (is => 'ro', lazy_build => 1);

sub send_email {
    my $self = shift;
    my %args = @_;

    my $body;
    my $template = "email/$args{template}";
    $self->template->process($template, $args{template_args}, \$body) 
        || die $self->template->error;

    my %headers = (
        From => '"VanTrash" <help@vantrash.ca>',
        To => $args{to},
        Subject => $args{subject},
    );
    my $email = Email::MIME->create(
        attributes => {
            content_type => 'text/plain',
            disposition => 'inline',
            charset => 'utf8',
        },
        body => $body,
    );
    $email->header_set( $_ => $headers{$_}) for keys %headers;

    $self->mailer->send($email);
}

sub _build_mailer {
    my $self = shift;

# Forces testing mode ON, set by unit tests.
#    $ENV{VT_EMAIL} ||= '/tmp/email';

    my $class;
    if (my $file = $ENV{VT_EMAIL}) {
        require Email::Send::IO;
        @Email::Send::IO::IO = ($file);
        $class = 'IO';
    }
    else {
        require Email::Send::Sendmail;
        $Email::Send::Sendmail::SENDMAIL = '/usr/sbin/sendmail';
        $class = 'Sendmail';
    }

    return Email::Send->new( { mailer => $class } );
}

sub _build_template {
    my $self = shift;
    return App::VanTrash::Template->new( base_path => $self->base_path );
}

1;