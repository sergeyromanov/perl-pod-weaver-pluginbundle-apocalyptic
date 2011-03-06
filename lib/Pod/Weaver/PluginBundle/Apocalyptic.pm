package Pod::Weaver::PluginBundle::Apocalyptic;

# ABSTRACT: Let the apocalypse generate your POD!

# The plugins we use ( excluding ones bundled in podweaver )
use Pod::Weaver::Config::Assembler 3.101632;	# basically sets the pod-weaver version
use Pod::Weaver::Section::SeeAlso 1.002;
use Pod::Weaver::Section::Support 1.003;
use Pod::Weaver::Section::WarrantyDisclaimer 0.103511;
use Pod::Weaver::Plugin::StopWords 1.001005;
use Pod::Weaver::Plugin::Encoding 0.01;
use Pod::Weaver::Plugin::EnsureUniqueSections 0.103531;
use Pod::Elemental::Transformer::List 0.101620;

# TODO follow up on those local patches:
# Section::WarrantyDisclaimer - specify the warranty version ( https://github.com/DarwinAwardWinner/Pod-Weaver-Section-WarrantyDisclaimer/pull/1 )
# Section::Legal - add extra line about LICENSE ( https://github.com/rjbs/pod-weaver/pull/4 )

sub _exp {
	Pod::Weaver::Config::Assembler->expand_package( $_[0] );
}

sub mvp_bundle_config {
	return (
		# some basics we need
		[ '@Apocalyptic/CorePrep',	_exp('@CorePrep'), {} ],

		# Move our special markers to the start of the POD
		[ '@Apocalyptic/Encoding',	_exp('-Encoding'), {} ],
		[ '@Apocalyptic/PodCoverage',	_exp('Region'), {
			region_name	=> 'Pod::Coverage',
			allow_nonpod	=> 1,
			flatten		=> 0,
		} ],
		[ '@Apocalyptic/StopWords',	_exp('StopWords'), {} ],

		# Start the POD!
		[ '@Apocalyptic/Name',		_exp('Name'), {} ],
		[ '@Apocalyptic/Version',	_exp('Version'), {
			format		=> 'This document describes v%v of %m - released %{LLLL dd, yyyy}d as part of %r.',
			is_verbatim	=> 1,
		} ],

		# The standard sections
		[ '@Apocalyptic/Synopsis',	_exp('Generic'), {
			header		=> 'SYNOPSIS',
		} ],
		[ '@Apocalyptic/Description',	_exp('Generic'), {
			header		=> 'DESCRIPTION',
			required	=> 1,
		} ],

		# Our subs
		[ '@Apocalyptic/Attributes',	_exp('Collect'), {
			header		=> 'ATTRIBUTES',
			command		=> 'attr',
		} ],
		[ '@Apocalyptic/Methods',	_exp('Collect'), {
			header		=> 'METHODS',
			command		=> 'method',
		} ],
		[ '@Apocalyptic/Functions',	_exp('Collect'), {
			header		=> 'FUNCTIONS',
			command		=> 'func',
		} ],

		# Anything that wasn't matched gets dumped here
		[ '@Apocalyptic/Leftovers',	_exp('Leftovers'), {} ],

		# The usual end of POD...
		[ '@Apocalyptic/SeeAlso',	_exp('SeeAlso'), {} ],
		[ '@Apocalyptic/Support',	_exp('Support'), {
			'irc'		=> [
				'irc.perl.org, #perl-help, Apocalypse',
				'irc.freenode.net, #perl, Apocal',
				'irc.efnet.org, #perl, Ap0cal',
			],
			'email'		=> 'APOCAL',
		} ],
		[ '@Apocalyptic/Authors',	_exp('Authors'), {} ],
		[ '@Apocalyptic/ACK',		_exp('Generic'), {
			header		=> 'ACKNOWLEDGEMENTS',
		} ],
		[ '@Apocalyptic/Legal',		_exp('Legal'), {
			# TODO wait for a version that includes this
			#license_file	=> 'LICENSE',
		} ],
		[ '@Apocalyptic/Warranty',	_exp('WarrantyDisclaimer'), {
			# TODO wait for a version that includes this
			#warranty	=> 'GPL_3',
		} ],

		# Mangle the entire POD
		[ '@Apocalyptic/ListTransformer',	_exp('-Transformer'), {
			transformer	=> 'List',
		} ],
		[ '@Apocalyptic/UniqueSections',	_exp('-EnsureUniqueSections'), {} ],
	);
}

1;

=for Pod::Coverage mvp_bundle_config

=head1 DESCRIPTION

In your F<weaver.ini>:

	[@Apocalyptic]

Or alternatively, in your L<Dist::Zilla> dist's F<dist.ini>:

	[PodWeaver]
	config_plugin = @Apocalyptic

This plugin bundle formats your POD and adds some sections and sets some custom options. Naturally, in order for
most of the plugins to work, you need to use this in conjunction with L<Dist::Zilla>.

It is nearly equivalent to the following in your F<weaver.ini>:

	[@CorePrep]			; setup the pod stuff
	[-Encoding]			; add the =encoding command to your POD via Pod::Weaver::Plugin::Encoding
	encoding = utf-8
	[Region / Pod::Coverage]	; move any Pod::Coverage markers to the top ( =for Pod::Coverage foo bar )
	[StopWords]			; gather our stopwords and add some extra ones via Pod::Weaver::Section::StopWords

	[Name]				; automatically generate the NAME section
	[Version]			; automatically generate the VERSION section
	format = This document describes v%v of %m - released %{LLLL dd, yyyy}d as part of %r.
	is_verbatim = 1

	[Generic / SYNOPSIS]		; move the SYNOPSIS section here, if it exists
	[Generic / DESCRIPTION]		; move the DESCRIPTION section here ( it is required to exist! )
	required = 1

	[Collect / ATTRIBUTES]		; get any POD marked as =attr and list them here
	command = attr
	[Collect / METHODS]		; get any POD marked as =method and list them here
	command = method
	[Collect / FUNCTIONS]		; get any POD marked as =func and list them here
	command = func

	[Leftovers]			; any other POD you use

	[SeeAlso]			; generate the SEE ALSO section via Pod::Weaver::Section::SeeAlso
	[Support]			; generate the SUPPORT section via Pod::Weaver::Section::Support ( only present in main module )
	irc = irc.perl.org, #perl-help, Apocalypse
	irc = irc.freenode.net, #perl, Apocal
	irc = irc.efnet.org, #perl, Ap0cal
	email = APOCAL
	[Authors]			; automatically generate the AUTHOR(S) section
	[Generic / ACKNOWLEDGEMENTS]	; move the ACKNOWLEDGEMENTS section here, if it exists
	[Legal]				; automatically generate the COPYRIGHT AND LICENSE section
	[WarrantyDisclaimer]		; automatically generate the DISCLAIMER OF WARRANTY section via Pod::Weaver::Section::WarrantyDisclaimer

	[-Transformer]
	transformer = List		; mangle all :list pod into proper lists via Pod::Elemental::Transformer::List
	[-EnsureUniqueSections]		; sanity check your sections to make sure they are unique via Pod::Weaver::Plugin::EnsureUniqueSections

If you need something to be configurable ( probably the Support section, ha! ) please let me know and I can add it in a future version.

=head1 SEE ALSO
Dist::Zilla
Pod::Weaver
Pod::Weaver::Plugin::Encoding
Pod::Weaver::Section::StopWords
Pod::Weaver::Section::SeeAlso
Pod::Weaver::Section::Support
Pod::Weaver::Section::WarrantyDisclaimer
Pod::Elemental::Transformer::List
Pod::Weaver::Plugin::EnsureUniqueSections

=head1 Future Plans

=head2 auto image in POD?

=begin :HTML
<p><img src="http://www.perl.org/i/icons/camel.png" width="600">Perl Camel!</p>
=end :HTML

Saw that in http://search.cpan.org/~wonko/Smolder-1.51/lib/Smolder.pm

Maybe we can make a transformer to automatically do that? ( =image http://blah.com/foo.png )

<jhannah> Apocalypse: ya, right? cool and dangerous and prone to FAIL as URLs become invalid... :/
<jhannah> I'd hate to see craptons of broken images on s.c.o   :(
<Apocalypse> Yeah jhannah it would be best if you could include the image in the dist itself... but that's a problem for another day :)
<jhannah> Apocalypse: it'd be trivial to include the .jpg in the .tgz... but what's the POD markup for that? and would s.c.o. do it correctly?
<jhannah> =begin HTML is ... eep
<Apocalypse> I think you could do it via sneaky means but it's prone to breakage
<Apocalypse> i.e. include it in dist as My-Foo-Dist/misc/image.png and link to it via s.c.o's "browse dist" directory
<Apocalypse> i.e. link to http://cpansearch.perl.org/src/WONKO/Smolder-1.51/misc/image.png
<Apocalypse> I should try that sneaky tactic and see if it works =]

=cut
