Contributions are welcome via pull request, although modifications may be requested.  If you're unsure about something, feel free to raise an issue first to allow discussion.

These things I consider to be important:

* Backwards compatbility.  I don't want to break existing code using this module.
* Documentation.

Technical details.  This module uses Dist::Zilla to release to CPAN.  This can throw people off as there is no Makefile.PL in the git repo.  Developement is possible without installing dist::zilla.  It is only requiredd for release to CPAN.

To install dependencies:

    cpanm --installdeps .

To run the tests.

   prove -l t
   
If you are a new contributor, please add yourself to the contributors list.  This is in the pod of the lib/Jenkins/API.pm and dist.ini to provide meta info.

Do not worry about the README, that is generated automatically from the pod when the module release is rolled.

Please ensure the Changes file is updated, but don't add a date, e.g.

    {{ $NEXT }}

              Your changes here....

    0.18      2021-05-22 08:50:23+01:00 Europe/London
