SUBDIRS = doxygen manual devref
dist_man1_MANS = form.1

.PHONY: clean-local update_version_man

clean-local:
	rm form.1

form.1: update_version_man
	$(UPDATE_VERSION_MAN)

dist-hook:
	$(DISTHOOK_VERSION_MAN)

if FIXED_VERSION

UPDATE_VERSION_MAN = \
	[ -f form.1 ] || $(LN_S) "$(srcdir)/form.1.in" form.1

DISTHOOK_VERSION_MAN = \
	cp "$(srcdir)/form.1" "$(distdir)/form.1"

else

UPDATE_VERSION_MAN = \
	$(SHELL) "$(top_srcdir)/scripts/git-version-gen.sh" -C "$(srcdir)" --man --date-format '%Y-%m-%d' -o form.1 && cat "$(srcdir)/form.1.in" >> form.1

DISTHOOK_VERSION_MAN = \
	$(SHELL) "$(top_srcdir)/scripts/git-version-gen.sh" -C "$(srcdir)" --man --date-format '%Y-%m-%d' -o "$(distdir)/form.1" && cat "$(srcdir)/form.1.in" >> "$(distdir)/form.1"

endif
