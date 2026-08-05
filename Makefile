SCRIPTS := nova.sh install.sh nova_completion.bash

define HELP
Usage: make <command>

with <command>:
  - check   : vérifie la syntaxe des scripts
  - patch   : bump de version patch, tag et publie (raccourci pour 'release BUMP=patch')
  - release : bump de version (BUMP=patch|minor|major, défaut minor), tag et publie sur la branche release
endef
export HELP

.PHONY: help
help:
	@echo "$$HELP"

.PHONY: check
check:
	@for f in $(SCRIPTS); do bash -n $$f || exit 1; done
	@command -v shellcheck >/dev/null 2>&1 && shellcheck $(SCRIPTS) || echo "shellcheck non installé, vérification ignorée"
	@printf '\033[32mcheck OK : scripts valides, prêt pour release.\033[0m\n'

.PHONY: patch
patch:
	${MAKE} release BUMP=patch

BUMP ?= minor

.PHONY: release
release:
	@git diff --quiet && git diff --cached --quiet || (echo "Arbre de travail non propre : commit ou stash d'abord." && exit 1)
	@[ "$$(git branch --show-current)" = "main" ] || (echo "Il faut être sur main pour lancer 'make release'." && exit 1)
	${MAKE} check
	@version=$$(cat VERSION.txt); \
	major=$$(echo $$version | cut -d. -f1); \
	minor=$$(echo $$version | cut -d. -f2); \
	patch=$$(echo $$version | cut -d. -f3); \
	case "$(BUMP)" in \
		major) major=$$((major + 1)); minor=0; patch=0 ;; \
		minor) minor=$$((minor + 1)); patch=0 ;; \
		patch) patch=$$((patch + 1)) ;; \
		*) echo "BUMP invalide : $(BUMP) (attendu major, minor ou patch)"; exit 1 ;; \
	esac; \
	new_version="$$major.$$minor.$$patch"; \
	echo "$$new_version" > VERSION.txt; \
	sed -i "s/^VERSION=\".*\"/VERSION=\"$$new_version\"/" nova.sh; \
	git add VERSION.txt nova.sh; \
	git commit -m "chore: bump version to $$new_version"; \
	git checkout release; \
	git merge --ff-only main; \
	git tag "$$new_version"; \
	git checkout main; \
	git push origin main release --tags
	@printf '\033[32mrelease OK : v%s taggée et poussée.\033[0m\n' "$$(cat VERSION.txt)"
