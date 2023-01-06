TARGET := Fdupes

SRCS := main.py
SRCS += config.py
SRCS += motors.py

VERB := @

all: $(SRCS) ctags
	$(VERB)nice -n 19 python3 $<

strace: $(SRCS) ctags
	$(VERB)strace -e trace=read,write nice -n 19 python3 $<

# vim: do_ctags
vim:
	$(VERB)echo vim $(SRCS) Makefile test.txt

doc: $(SRCS)
	pydoc3 $<


CTAGS = ctags
CTAGSFLAGS = -h ".py" --python-kinds=-i

ctags:
	$(VERB)$(CTAGS) $(CTAGSFLAGS) $(SRCS)


lint: $(SRCS)
	$(VERBOSE)pylint $^


flake8: $(SRCS)
	$(VERBOSE)flake8 $^


mypy: $(SRCS)
	$(VERBOSE)mypy $^


zip:


dox:
	$(VERBOSE)doxygen main.dox
	$(VERBOSE)$(MAKE) -C ./doc/latex
	$(VERBOSE)cp ./doc/latex/refman.pdf ./


# Minimal makefile for Sphinx documentation
#

# You can set these variables from the command line, and also
# from the environment for the first two.
SPHINXOPTS    ?=
SPHINXBUILD   ?= sphinx-build
SOURCEDIR     = .
BUILDDIR      = _build

# Put it first so that "make" without argument is like "make help".
help:
	@$(SPHINXBUILD) -M help "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)

.PHONY: help Makefile

# Catch-all target: route all unknown targets to Sphinx using the new
# "make mode" option.  $(O) is meant as a shortcut for $(SPHINXOPTS).
# %: Makefile
html: Makefile
	@$(SPHINXBUILD) -M $@ "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)


# Show variables (for debug use only.)
GREEN=\e[1;32m
NORM =\e[0m

show:
	$(VERBOSE)echo -e '$(GREEN)TARGET    :$(NORM) $(TARGET)'
	$(VERBOSE)echo -e '$(GREEN)SRCS      :$(NORM) $(SRCS)'
	$(VERBOSE)echo -e '$(GREEN)CTAGS     :$(NORM) $(CTAGS)'
	$(VERBOSE)echo -e '$(GREEN)CTAGSFLAGS:$(NORM) $(CTAGSFLAGS)' 


.phony: all vim ctags zip dox show

# $@ Имя цели обрабатываемого правила
# $< Имя первой зависимости обрабатываемого правила
# $^ Список всех зависимостей обрабатываемого правила
