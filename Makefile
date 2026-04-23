UNAME := $(shell uname -s)

ifeq ($(UNAME),Linux)
    EDITOR_BASE = /home/joseph/work/PersoSimEditor
    PERSOSIM_BASE = /home/joseph/work/PersoSim
    CP_SEP = :
else
    EDITOR_BASE = /c/Users/zozoz/work/PersoSimEditor
    PERSOSIM_BASE = /c/Users/zozoz/work/PersoSim
    CP_SEP = ;
endif

PLATFORM ?= linux
VERSION ?= 1.0.0

EDITOR_PLUGINS = $(EDITOR_BASE)/$(PLATFORM)/plugins
EDITOR_RCP_JAR = $(EDITOR_PLUGINS)/de.persosim.editor.rcp_1.4.0.20251112.jar
EDITOR_UI_JAR = $(EDITOR_PLUGINS)/de.persosim.editor.ui_1.4.0.20251112.jar

EDITOR_CLASSPATH = $(EDITOR_PLUGINS)/*$(CP_SEP)$(EDITOR_PLUGINS)/de.persosim.simulator_1.4.0.20251112$(CP_SEP)$(EDITOR_UI_JAR)

# Extract patches
extract-editor-patches:
	cd patches && jar xf $(EDITOR_RCP_JAR) Application.e4xmi
	cd patches && jar xf $(EDITOR_UI_JAR) fragment.e4xmi
	@echo "Extracted patches"

# Backup
backup-editor:
	cp $(EDITOR_RCP_JAR) $(EDITOR_RCP_JAR).bak
	cp $(EDITOR_UI_JAR) $(EDITOR_UI_JAR).bak
	@echo "Backups created"

# Restore
restore-editor:
	cp $(EDITOR_RCP_JAR).bak $(EDITOR_RCP_JAR)
	cp $(EDITOR_UI_JAR).bak $(EDITOR_UI_JAR)
	@echo "Restored from backups"

# Compile
compile-editor:
	javac -cp "$(EDITOR_CLASSPATH)" PersoEditorView.java -d output/
	@echo "Compilation done"

# Patch
patch-application-editor: backup-editor
	cd patches && jar uf $(EDITOR_RCP_JAR) Application.e4xmi

patch-fragment-editor:
	cd patches && jar uf $(EDITOR_UI_JAR) fragment.e4xmi

deploy-editor:
	cd output && jar uf $(EDITOR_UI_JAR) de/persosim/editor/ui/editor/PersoEditorView.class
	@echo "Deployed PersoEditorView.class"

# Full patch
patch-editor: backup-editor compile-editor patch-application-editor patch-fragment-editor deploy-editor
	@echo "Editor fully patched!"

# Build zip
build-editor:
	rm -rf persosim-editor@sqm-$(VERSION)-$(PLATFORM)
	cp -r $(PLATFORM) persosim-editor@sqm-$(VERSION)-$(PLATFORM)
	zip -r persosim-editor@sqm-$(VERSION)-$(PLATFORM).zip persosim-editor@sqm-$(VERSION)-$(PLATFORM)/
	rm -rf persosim-editor@sqm-$(VERSION)-$(PLATFORM)
	@echo "Build done: persosim-editor@sqm-$(VERSION)-$(PLATFORM).zip"
