PLATFORM ?= linux
EDITOR_PLUGINS = /home/joseph/work/PersoSimEditor/$(PLATFORM)/plugins
EDITOR_UI_JAR = $(EDITOR_PLUGINS)/de.persosim.editor.ui_1.4.0.20251112.jar
CLASSPATH = $(EDITOR_PLUGINS)/*:$(EDITOR_PLUGINS)/de.persosim.simulator_1.4.0.20251112

compile-editor:
	javac -cp "$(CLASSPATH)" PersoEditorView.java -d output/

backup-editor:
	cp $(EDITOR_UI_JAR) $(EDITOR_UI_JAR).bak
	@echo "Backup created at $(EDITOR_UI_JAR).bak"

restore-editor:
	cp $(EDITOR_UI_JAR).bak $(EDITOR_UI_JAR)
	@echo "Restored from backup"

deploy-editor:
	cd output && jar uf $(EDITOR_UI_JAR) de/persosim/editor/ui/editor/PersoEditorView.class
	@echo "Deployed PersoEditorView.class"

patch-editor: compile-editor backup-editor deploy-editor
	@echo "Editor patched successfully!"
