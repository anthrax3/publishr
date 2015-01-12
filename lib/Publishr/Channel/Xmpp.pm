package Publishr::Channel::Xmpp;

use strict;
use warnings;

use Publishr;

sub new {
    my $class = shift;
    my (%params) = @_;

    my $self = {};
    bless $self, $class;

    eval { require Net::XMPP }
      or die "Net::XMPP is required\n";

    $self->{hostname} = $params{hostname};
    $self->{username} = $params{username};
    $self->{password} = $params{password};
    $self->{to}       = $params{to};

    return $self;
}

sub publish {
    my $self = shift;
    my ($message) = @_;

    my $conn = Net::XMPP::Client->new;

    my $status = $conn->Connect(hostname => $self->{hostname});
    die $! unless defined $status;

    my @auth = $conn->AuthSend(
        username => $self->{username},
        password => $self->{password},
        resource => "Publishr/$Publishr::VERSION"
    );
    die "$auth[0] - $auth[1]" unless $auth[0] eq 'ok';

    $conn->MessageSend(
        to   => $self->{to},
        body => $message->{status} . ' ' . $message->{link},
        type => 'chat',
    );

    $conn->Disconnect;

    return $self;
}

1;
