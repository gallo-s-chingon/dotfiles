"use strict";
var __create = Object.create;
var __defProp = Object.defineProperty;
var __getOwnPropDesc = Object.getOwnPropertyDescriptor;
var __getOwnPropNames = Object.getOwnPropertyNames;
var __getProtoOf = Object.getPrototypeOf;
var __hasOwnProp = Object.prototype.hasOwnProperty;
var __export = (target, all) => {
  for (var name in all)
    __defProp(target, name, { get: all[name], enumerable: true });
};
var __copyProps = (to, from, except, desc) => {
  if (from && typeof from === "object" || typeof from === "function") {
    for (let key of __getOwnPropNames(from))
      if (!__hasOwnProp.call(to, key) && key !== except)
        __defProp(to, key, { get: () => from[key], enumerable: !(desc = __getOwnPropDesc(from, key)) || desc.enumerable });
  }
  return to;
};
var __toESM = (mod, isNodeMode, target) => (target = mod != null ? __create(__getProtoOf(mod)) : {}, __copyProps(
  // If the importer is in node compatibility mode or this is not an ESM
  // file that has been converted to a CommonJS file using a Babel-
  // compatible transform (i.e. "__esModule" has not been set), then set
  // "default" to the CommonJS "module.exports" for node compatibility.
  isNodeMode || !mod || !mod.__esModule ? __defProp(target, "default", { value: mod, enumerable: true }) : target,
  mod
));
var __toCommonJS = (mod) => __copyProps(__defProp({}, "__esModule", { value: true }), mod);

// src/fabric-pattern.tsx
var fabric_pattern_exports = {};
__export(fabric_pattern_exports, {
  default: () => Command
});
module.exports = __toCommonJS(fabric_pattern_exports);
var import_api2 = require("@raycast/api");
var import_react2 = require("react");
var import_api3 = require("@raycast/api");

// src/hooks/useFabricProcessor.ts
var import_react = require("react");
var import_api = require("@raycast/api");
var import_child_process2 = require("child_process");
var import_util2 = require("util");
var import_fs = __toESM(require("fs"));
var import_path = __toESM(require("path"));

// src/utils/urlFetcher.ts
var import_child_process = require("child_process");
var import_util = require("util");
var execAsync = (0, import_util.promisify)(import_child_process.exec);
async function fetchUrlContent(url) {
  const headCommand = `curl -I -L -s "${url}"`;
  try {
    const { stdout: headers } = await execAsync(headCommand);
    const contentType = headers.toLowerCase();
    if (headers.toLowerCase().includes("content-type: application/pdf")) {
      try {
        const jinaUrl = `https://r.jina.ai/${encodeURIComponent(url)}`;
        const { stdout: stdout2 } = await execAsync(`curl -L -s "${jinaUrl}"`);
        return stdout2;
      } catch (pdfError) {
        throw new Error(`Failed to process PDF: ${pdfError}. The r.jina.ai service might be unavailable.`);
      }
    }
    const { stdout } = await execAsync(`curl -L -s -A "Mozilla/5.0" "${url}"`);
    if (!stdout) {
      throw new Error("No content available from URL");
    }
    return stdout;
  } catch (error) {
    throw new Error(`Failed to fetch URL: ${error}`);
  }
}

// src/hooks/useFabricProcessor.ts
var execAsync2 = (0, import_util2.promisify)(import_child_process2.exec);
function expandTilde(filePath) {
  if (filePath.startsWith("~/")) {
    return import_path.default.join(process.env.HOME || "", filePath.slice(2));
  }
  return filePath;
}
var PATHS = (() => {
  const preferences = (0, import_api.getPreferenceValues)();
  return {
    FABRIC: expandTilde(preferences.fabricPath || import_path.default.join(process.env.HOME || "", "go/bin/fabric")),
    SAVE: expandTilde(preferences.savePath || import_path.default.join(process.env.HOME || "", ".local/bin/save")),
    PATTERNS: expandTilde(preferences.patternsPath || import_path.default.join(process.env.HOME || "", ".config/fabric/patterns")),
    SAVE_TARGET: preferences.saveTargetPath ? expandTilde(preferences.saveTargetPath) : void 0,
    MODEL: preferences.model || void 0
  };
})();
var getPatternDescription = async (patternName) => {
  try {
    const systemPath = import_path.default.join(PATHS.PATTERNS, patternName, "system.md");
    const content = await import_fs.default.promises.readFile(systemPath, "utf-8");
    return content.trim();
  } catch (error) {
    return "";
  }
};
function useFabricProcessor() {
  const [isProcessing, setIsProcessing] = (0, import_react.useState)(false);
  const createTempFile = async (content) => {
    const tempFile = import_path.default.join(process.env.TMPDIR || "/tmp", `raycast-fabric-${Date.now()}.txt`);
    await import_fs.default.promises.writeFile(tempFile, content);
    return tempFile;
  };
  const cleanupTempFile = async (tempFile) => {
    try {
      await import_fs.default.promises.unlink(tempFile);
    } catch (error) {
      console.error("Error cleaning up temp file:", error);
    }
  };
  const executeCommand = async (command) => {
    return execAsync2(command, {
      env: {
        ...process.env,
        PATH: `/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:${process.env.HOME}/go/bin:${process.env.HOME}/.local/bin:${process.env.PATH || ""}`
      },
      shell: "/bin/bash"
    });
  };
  const processContent = async (pattern, input, saveFileName) => {
    setIsProcessing(true);
    try {
      const fabricCmd = `${PATHS.FABRIC} --pattern ${pattern}${PATHS.MODEL ? ` -m "${PATHS.MODEL}"` : ""}`;
      let command;
      if (input.startsWith("yt --transcript ")) {
        command = `${input} | ${fabricCmd}`;
      } else if (input.startsWith("-u ")) {
        const url = input.slice(3);
        const content = await fetchUrlContent(url);
        const tempFile = await createTempFile(content);
        try {
          command = `cat "${tempFile}" | ${fabricCmd}`;
          const { stdout } = await executeCommand(command);
          await cleanupTempFile(tempFile);
          return stdout;
        } catch (error2) {
          await cleanupTempFile(tempFile);
          throw error2;
        }
      } else {
        command = `cat "${await createTempFile(input)}" | ${fabricCmd}`;
      }
      console.log(`Executing command: ${command}`);
      const { stdout: output, stderr: error } = await executeCommand(command);
      console.log(`Output: ${output}`);
      console.log(`Error: ${error}`);
      if (error) {
        throw new Error(`Fabric error: ${error}`);
      }
      if (saveFileName) {
        await saveOutput(output, saveFileName);
      }
      return output;
    } finally {
      setIsProcessing(false);
    }
  };
  const saveOutput = async (content, fileName) => {
    const tempFile = await createTempFile(content);
    const saveCommand = PATHS.SAVE_TARGET ? `cat "${tempFile}" | ${PATHS.SAVE} -d "${PATHS.SAVE_TARGET}" "${fileName}"` : `cat "${tempFile}" | ${PATHS.SAVE} "${fileName}"`;
    await executeCommand(saveCommand);
    if (PATHS.SAVE_TARGET) {
      const currentDate = (/* @__PURE__ */ new Date()).toISOString().split("T")[0];
      const savedFile = import_path.default.join(PATHS.SAVE_TARGET, `${currentDate}-${fileName}.md`);
      const fileExists = await import_fs.default.promises.access(savedFile).then(() => true).catch(() => false);
      if (!fileExists) throw new Error(`File not saved at: ${savedFile}`);
    }
    await (0, import_api.showToast)({
      style: import_api.Toast.Style.Success,
      title: "Success",
      message: `File saved as: ${fileName}`
    });
  };
  const loadPatterns = async () => {
    const files = await import_fs.default.promises.readdir(PATHS.PATTERNS);
    const patterns = await Promise.all(
      files.filter(
        (file) => file !== ".DS_Store" && file !== "raycast" && !file.startsWith(".")
      ).map(async (file) => ({
        name: import_path.default.basename(file, import_path.default.extname(file)),
        path: import_path.default.join(PATHS.PATTERNS, file),
        description: await getPatternDescription(file)
      }))
    );
    return patterns;
  };
  return { processContent, isProcessing, loadPatterns };
}

// src/fabric-pattern.tsx
var import_jsx_runtime = require("react/jsx-runtime");
function ResultView({ content, fileName, isLoading }) {
  return /* @__PURE__ */ (0, import_jsx_runtime.jsx)(
    import_api2.Detail,
    {
      isLoading,
      markdown: content || "No content available",
      actions: /* @__PURE__ */ (0, import_jsx_runtime.jsxs)(import_api2.ActionPanel, { children: [
        /* @__PURE__ */ (0, import_jsx_runtime.jsx)(import_api2.Action.CopyToClipboard, { content: content || "" }),
        /* @__PURE__ */ (0, import_jsx_runtime.jsx)(import_api2.Action.Push, { title: "Back to Patterns", target: /* @__PURE__ */ (0, import_jsx_runtime.jsx)(Command, {}) })
      ] }),
      metadata: fileName ? /* @__PURE__ */ (0, import_jsx_runtime.jsx)(import_api2.Detail.Metadata, { children: /* @__PURE__ */ (0, import_jsx_runtime.jsx)(import_api2.Detail.Metadata.Label, { title: "Saved As", text: fileName }) }) : null
    }
  );
}
function Command() {
  const navigation = (0, import_api3.useNavigation)();
  const { processContent, isProcessing, loadPatterns } = useFabricProcessor();
  const [patterns, setPatterns] = (0, import_react2.useState)([]);
  const [isLoading, setIsLoading] = (0, import_react2.useState)(true);
  const [isUrlMode, setIsUrlMode] = (0, import_react2.useState)(false);
  const [inputMode, setInputMode] = (0, import_react2.useState)("clipboard");
  (0, import_react2.useEffect)(() => {
    const fetchPatterns = async () => {
      try {
        const patternsData = await loadPatterns();
        setPatterns(patternsData);
      } catch (error) {
        await (0, import_api2.showToast)({
          style: import_api2.Toast.Style.Failure,
          title: "Error",
          message: `Failed to load patterns: ${error}`
        });
        setPatterns([]);
      } finally {
        setIsLoading(false);
      }
    };
    fetchPatterns();
  }, []);
  const handleDropdownChange = (value) => {
    setInputMode(value);
  };
  const handleSubmit = async (pattern, values) => {
    try {
      let input = "";
      if (inputMode === "url") {
        if (!values.url) {
          await (0, import_api2.showToast)({
            style: import_api2.Toast.Style.Failure,
            title: "Error",
            message: "URL is required"
          });
          return;
        }
        input = `-u ${values.url}`;
      } else if (inputMode === "youtube") {
        if (!values.youtubeUrl) {
          await (0, import_api2.showToast)({
            style: import_api2.Toast.Style.Failure,
            title: "Error",
            message: "YouTube URL is required"
          });
          return;
        }
        input = `yt --transcript ${values.youtubeUrl}`;
      } else {
        input = await import_api2.Clipboard.readText() || "";
      }
      navigation.pop();
      navigation.push(/* @__PURE__ */ (0, import_jsx_runtime.jsx)(ResultView, { content: "Processing...", isLoading: true, fileName: values.saveFileName }));
      const output = await processContent(pattern.name, input, values.saveFileName);
      navigation.pop();
      navigation.push(/* @__PURE__ */ (0, import_jsx_runtime.jsx)(ResultView, { content: output, fileName: values.saveFileName, isLoading: false }));
    } catch (error) {
      await (0, import_api2.showToast)({ style: import_api2.Toast.Style.Failure, title: "Error", message: String(error) });
      navigation.pop();
      navigation.push(/* @__PURE__ */ (0, import_jsx_runtime.jsx)(ResultView, { isLoading: false, fileName: values.saveFileName }));
    }
  };
  return /* @__PURE__ */ (0, import_jsx_runtime.jsx)(
    import_api2.List,
    {
      isLoading,
      searchBarPlaceholder: "Search patterns...",
      searchBarAccessory: /* @__PURE__ */ (0, import_jsx_runtime.jsxs)(
        import_api2.List.Dropdown,
        {
          tooltip: "Input Source",
          storeValue: true,
          onChange: handleDropdownChange,
          children: [
            /* @__PURE__ */ (0, import_jsx_runtime.jsx)(import_api2.List.Dropdown.Item, { title: "From Clipboard", value: "clipboard" }),
            /* @__PURE__ */ (0, import_jsx_runtime.jsx)(import_api2.List.Dropdown.Item, { title: "From URL", value: "url" }),
            /* @__PURE__ */ (0, import_jsx_runtime.jsx)(import_api2.List.Dropdown.Item, { title: "From YouTube", value: "youtube" })
          ]
        }
      ),
      isShowingDetail: true,
      children: patterns.map((pattern) => /* @__PURE__ */ (0, import_jsx_runtime.jsx)(
        import_api2.List.Item,
        {
          title: pattern.name,
          detail: /* @__PURE__ */ (0, import_jsx_runtime.jsx)(
            import_api2.List.Item.Detail,
            {
              markdown: pattern.description || "*No description available*"
            }
          ),
          actions: /* @__PURE__ */ (0, import_jsx_runtime.jsx)(import_api2.ActionPanel, { children: /* @__PURE__ */ (0, import_jsx_runtime.jsx)(
            import_api2.Action.Push,
            {
              title: "Process with Pattern",
              target: /* @__PURE__ */ (0, import_jsx_runtime.jsxs)(import_api2.Form, { actions: /* @__PURE__ */ (0, import_jsx_runtime.jsx)(import_api2.ActionPanel, { children: /* @__PURE__ */ (0, import_jsx_runtime.jsx)(
                import_api2.Action.SubmitForm,
                {
                  title: "Process",
                  icon: import_api2.Icon.Terminal,
                  onSubmit: (values) => handleSubmit(pattern, values)
                }
              ) }), isLoading: isProcessing, children: [
                inputMode === "url" && /* @__PURE__ */ (0, import_jsx_runtime.jsx)(
                  import_api2.Form.TextField,
                  {
                    id: "url",
                    title: "URL",
                    placeholder: "Enter URL to process"
                  }
                ),
                inputMode === "youtube" && /* @__PURE__ */ (0, import_jsx_runtime.jsx)(
                  import_api2.Form.TextField,
                  {
                    id: "youtubeUrl",
                    title: "YouTube URL",
                    placeholder: "Enter YouTube URL"
                  }
                ),
                /* @__PURE__ */ (0, import_jsx_runtime.jsx)(
                  import_api2.Form.TextField,
                  {
                    id: "saveFileName",
                    title: "Save As (Optional)",
                    placeholder: "Enter filename to save"
                  }
                )
              ] })
            }
          ) })
        },
        pattern.name
      ))
    }
  );
}
//# sourceMappingURL=data:application/json;base64,ewogICJ2ZXJzaW9uIjogMywKICAic291cmNlcyI6IFsiLi4vLi4vZmFicmljLXJheWNhc3QtZXh0ZW5zaW9uL3NyYy9mYWJyaWMtcGF0dGVybi50c3giLCAiLi4vLi4vZmFicmljLXJheWNhc3QtZXh0ZW5zaW9uL3NyYy9ob29rcy91c2VGYWJyaWNQcm9jZXNzb3IudHMiLCAiLi4vLi4vZmFicmljLXJheWNhc3QtZXh0ZW5zaW9uL3NyYy91dGlscy91cmxGZXRjaGVyLnRzIl0sCiAgInNvdXJjZXNDb250ZW50IjogWyJpbXBvcnQgeyBMaXN0LCBBY3Rpb25QYW5lbCwgQWN0aW9uLCBGb3JtLCBJY29uLCBzaG93VG9hc3QsIFRvYXN0LCBDbGlwYm9hcmQsIERldGFpbCB9IGZyb20gXCJAcmF5Y2FzdC9hcGlcIjtcbmltcG9ydCB7IHVzZVN0YXRlLCB1c2VFZmZlY3QgfSBmcm9tIFwicmVhY3RcIjtcbmltcG9ydCB7IHVzZU5hdmlnYXRpb24gfSBmcm9tIFwiQHJheWNhc3QvYXBpXCI7XG5pbXBvcnQgZnMgZnJvbSBcImZzXCI7XG5pbXBvcnQgcGF0aCBmcm9tIFwicGF0aFwiO1xuaW1wb3J0IHsgdXNlRmFicmljUHJvY2Vzc29yLCBQQVRIUyB9IGZyb20gXCIuL2hvb2tzL3VzZUZhYnJpY1Byb2Nlc3NvclwiO1xuXG5pbnRlcmZhY2UgUGF0dGVybiB7XG4gIG5hbWU6IHN0cmluZztcbiAgcGF0aDogc3RyaW5nO1xuICBkZXNjcmlwdGlvbj86IHN0cmluZztcbn1cblxuZnVuY3Rpb24gUmVzdWx0Vmlldyh7IGNvbnRlbnQsIGZpbGVOYW1lLCBpc0xvYWRpbmcgfTogeyBjb250ZW50Pzogc3RyaW5nOyBmaWxlTmFtZT86IHN0cmluZzsgaXNMb2FkaW5nOiBib29sZWFuIH0pIHtcbiAgcmV0dXJuIChcbiAgICA8RGV0YWlsXG4gICAgICBpc0xvYWRpbmc9e2lzTG9hZGluZ31cbiAgICAgIG1hcmtkb3duPXtjb250ZW50IHx8IFwiTm8gY29udGVudCBhdmFpbGFibGVcIn1cbiAgICAgIGFjdGlvbnM9e1xuICAgICAgICA8QWN0aW9uUGFuZWw+XG4gICAgICAgICAgPEFjdGlvbi5Db3B5VG9DbGlwYm9hcmQgY29udGVudD17Y29udGVudCB8fCBcIlwifSAvPlxuICAgICAgICAgIDxBY3Rpb24uUHVzaCB0aXRsZT1cIkJhY2sgdG8gUGF0dGVybnNcIiB0YXJnZXQ9ezxDb21tYW5kIC8+fSAvPlxuICAgICAgICA8L0FjdGlvblBhbmVsPlxuICAgICAgfVxuICAgICAgbWV0YWRhdGE9e2ZpbGVOYW1lID8gPERldGFpbC5NZXRhZGF0YT48RGV0YWlsLk1ldGFkYXRhLkxhYmVsIHRpdGxlPVwiU2F2ZWQgQXNcIiB0ZXh0PXtmaWxlTmFtZX0gLz48L0RldGFpbC5NZXRhZGF0YT4gOiBudWxsfVxuICAgIC8+XG4gICk7XG59XG5cbmV4cG9ydCBkZWZhdWx0IGZ1bmN0aW9uIENvbW1hbmQoKSB7XG4gIGNvbnN0IG5hdmlnYXRpb24gPSB1c2VOYXZpZ2F0aW9uKCk7XG4gIGNvbnN0IHsgcHJvY2Vzc0NvbnRlbnQsIGlzUHJvY2Vzc2luZywgbG9hZFBhdHRlcm5zIH0gPSB1c2VGYWJyaWNQcm9jZXNzb3IoKTtcbiAgY29uc3QgW3BhdHRlcm5zLCBzZXRQYXR0ZXJuc10gPSB1c2VTdGF0ZTxQYXR0ZXJuW10+KFtdKTtcbiAgY29uc3QgW2lzTG9hZGluZywgc2V0SXNMb2FkaW5nXSA9IHVzZVN0YXRlKHRydWUpO1xuICBjb25zdCBbaXNVcmxNb2RlLCBzZXRJc1VybE1vZGVdID0gdXNlU3RhdGUoZmFsc2UpO1xuICBjb25zdCBbaW5wdXRNb2RlLCBzZXRJbnB1dE1vZGVdID0gdXNlU3RhdGU8XCJjbGlwYm9hcmRcIiB8IFwidXJsXCIgfCBcInlvdXR1YmVcIj4oXCJjbGlwYm9hcmRcIik7XG5cbiAgdXNlRWZmZWN0KCgpID0+IHtcbiAgICBjb25zdCBmZXRjaFBhdHRlcm5zID0gYXN5bmMgKCkgPT4ge1xuICAgICAgdHJ5IHtcbiAgICAgICAgY29uc3QgcGF0dGVybnNEYXRhID0gYXdhaXQgbG9hZFBhdHRlcm5zKCk7XG4gICAgICAgIHNldFBhdHRlcm5zKHBhdHRlcm5zRGF0YSk7XG4gICAgICB9IGNhdGNoIChlcnJvcikge1xuICAgICAgICBhd2FpdCBzaG93VG9hc3Qoe1xuICAgICAgICAgIHN0eWxlOiBUb2FzdC5TdHlsZS5GYWlsdXJlLFxuICAgICAgICAgIHRpdGxlOiBcIkVycm9yXCIsXG4gICAgICAgICAgbWVzc2FnZTogYEZhaWxlZCB0byBsb2FkIHBhdHRlcm5zOiAke2Vycm9yfWBcbiAgICAgICAgfSk7XG4gICAgICAgIHNldFBhdHRlcm5zKFtdKTtcbiAgICAgIH0gZmluYWxseSB7XG4gICAgICAgIHNldElzTG9hZGluZyhmYWxzZSk7XG4gICAgICB9XG4gICAgfTtcblxuICAgIGZldGNoUGF0dGVybnMoKTtcbiAgfSwgW10pO1xuXG4gIGNvbnN0IGhhbmRsZURyb3Bkb3duQ2hhbmdlID0gKHZhbHVlOiBzdHJpbmcpID0+IHtcbiAgICBzZXRJbnB1dE1vZGUodmFsdWUgYXMgXCJjbGlwYm9hcmRcIiB8IFwidXJsXCIgfCBcInlvdXR1YmVcIik7XG4gIH07XG5cbiAgY29uc3QgaGFuZGxlU3VibWl0ID0gYXN5bmMgKHBhdHRlcm46IFBhdHRlcm4sIHZhbHVlczogeyBcbiAgICBzYXZlRmlsZU5hbWU/OiBzdHJpbmc7IFxuICAgIHVybD86IHN0cmluZzsgXG4gICAgeW91dHViZVVybD86IHN0cmluZyBcbiAgfSkgPT4ge1xuICAgIHRyeSB7XG4gICAgICBsZXQgaW5wdXQgPSBcIlwiO1xuICAgICAgXG4gICAgICBpZiAoaW5wdXRNb2RlID09PSBcInVybFwiKSB7XG4gICAgICAgIGlmICghdmFsdWVzLnVybCkge1xuICAgICAgICAgIGF3YWl0IHNob3dUb2FzdCh7IFxuICAgICAgICAgICAgc3R5bGU6IFRvYXN0LlN0eWxlLkZhaWx1cmUsIFxuICAgICAgICAgICAgdGl0bGU6IFwiRXJyb3JcIiwgXG4gICAgICAgICAgICBtZXNzYWdlOiBcIlVSTCBpcyByZXF1aXJlZFwiIFxuICAgICAgICAgIH0pO1xuICAgICAgICAgIHJldHVybjtcbiAgICAgICAgfVxuICAgICAgICBpbnB1dCA9IGAtdSAke3ZhbHVlcy51cmx9YDtcbiAgICAgIH0gZWxzZSBpZiAoaW5wdXRNb2RlID09PSBcInlvdXR1YmVcIikge1xuICAgICAgICBpZiAoIXZhbHVlcy55b3V0dWJlVXJsKSB7XG4gICAgICAgICAgYXdhaXQgc2hvd1RvYXN0KHsgXG4gICAgICAgICAgICBzdHlsZTogVG9hc3QuU3R5bGUuRmFpbHVyZSwgXG4gICAgICAgICAgICB0aXRsZTogXCJFcnJvclwiLCBcbiAgICAgICAgICAgIG1lc3NhZ2U6IFwiWW91VHViZSBVUkwgaXMgcmVxdWlyZWRcIiBcbiAgICAgICAgICB9KTtcbiAgICAgICAgICByZXR1cm47XG4gICAgICAgIH1cbiAgICAgICAgaW5wdXQgPSBgeXQgLS10cmFuc2NyaXB0ICR7dmFsdWVzLnlvdXR1YmVVcmx9YDtcbiAgICAgIH0gZWxzZSB7XG4gICAgICAgIGlucHV0ID0gYXdhaXQgQ2xpcGJvYXJkLnJlYWRUZXh0KCkgfHwgXCJcIjtcbiAgICAgIH1cblxuICAgICAgbmF2aWdhdGlvbi5wb3AoKTtcbiAgICAgIG5hdmlnYXRpb24ucHVzaCg8UmVzdWx0VmlldyBjb250ZW50PVwiUHJvY2Vzc2luZy4uLlwiIGlzTG9hZGluZz17dHJ1ZX0gZmlsZU5hbWU9e3ZhbHVlcy5zYXZlRmlsZU5hbWV9IC8+KTtcbiAgICAgIFxuICAgICAgY29uc3Qgb3V0cHV0ID0gYXdhaXQgcHJvY2Vzc0NvbnRlbnQocGF0dGVybi5uYW1lLCBpbnB1dCwgdmFsdWVzLnNhdmVGaWxlTmFtZSk7XG4gICAgICBcbiAgICAgIG5hdmlnYXRpb24ucG9wKCk7XG4gICAgICBuYXZpZ2F0aW9uLnB1c2goPFJlc3VsdFZpZXcgY29udGVudD17b3V0cHV0fSBmaWxlTmFtZT17dmFsdWVzLnNhdmVGaWxlTmFtZX0gaXNMb2FkaW5nPXtmYWxzZX0gLz4pO1xuICAgIH0gY2F0Y2ggKGVycm9yKSB7XG4gICAgICBhd2FpdCBzaG93VG9hc3QoeyBzdHlsZTogVG9hc3QuU3R5bGUuRmFpbHVyZSwgdGl0bGU6IFwiRXJyb3JcIiwgbWVzc2FnZTogU3RyaW5nKGVycm9yKSB9KTtcbiAgICAgIG5hdmlnYXRpb24ucG9wKCk7XG4gICAgICBuYXZpZ2F0aW9uLnB1c2goPFJlc3VsdFZpZXcgaXNMb2FkaW5nPXtmYWxzZX0gZmlsZU5hbWU9e3ZhbHVlcy5zYXZlRmlsZU5hbWV9IC8+KTtcbiAgICB9XG4gIH07XG5cbiAgcmV0dXJuIChcbiAgICA8TGlzdFxuICAgICAgaXNMb2FkaW5nPXtpc0xvYWRpbmd9XG4gICAgICBzZWFyY2hCYXJQbGFjZWhvbGRlcj1cIlNlYXJjaCBwYXR0ZXJucy4uLlwiXG4gICAgICBzZWFyY2hCYXJBY2Nlc3Nvcnk9e1xuICAgICAgICA8TGlzdC5Ecm9wZG93biBcbiAgICAgICAgICB0b29sdGlwPVwiSW5wdXQgU291cmNlXCIgXG4gICAgICAgICAgc3RvcmVWYWx1ZT17dHJ1ZX0gXG4gICAgICAgICAgb25DaGFuZ2U9e2hhbmRsZURyb3Bkb3duQ2hhbmdlfVxuICAgICAgICA+XG4gICAgICAgICAgPExpc3QuRHJvcGRvd24uSXRlbSB0aXRsZT1cIkZyb20gQ2xpcGJvYXJkXCIgdmFsdWU9XCJjbGlwYm9hcmRcIiAvPlxuICAgICAgICAgIDxMaXN0LkRyb3Bkb3duLkl0ZW0gdGl0bGU9XCJGcm9tIFVSTFwiIHZhbHVlPVwidXJsXCIgLz5cbiAgICAgICAgICA8TGlzdC5Ecm9wZG93bi5JdGVtIHRpdGxlPVwiRnJvbSBZb3VUdWJlXCIgdmFsdWU9XCJ5b3V0dWJlXCIgLz5cbiAgICAgICAgPC9MaXN0LkRyb3Bkb3duPlxuICAgICAgfVxuICAgICAgaXNTaG93aW5nRGV0YWlsXG4gICAgPlxuICAgICAge3BhdHRlcm5zLm1hcCgocGF0dGVybikgPT4gKFxuICAgICAgICA8TGlzdC5JdGVtXG4gICAgICAgICAga2V5PXtwYXR0ZXJuLm5hbWV9XG4gICAgICAgICAgdGl0bGU9e3BhdHRlcm4ubmFtZX1cbiAgICAgICAgICBkZXRhaWw9e1xuICAgICAgICAgICAgPExpc3QuSXRlbS5EZXRhaWwgXG4gICAgICAgICAgICAgIG1hcmtkb3duPXtwYXR0ZXJuLmRlc2NyaXB0aW9uIHx8ICcqTm8gZGVzY3JpcHRpb24gYXZhaWxhYmxlKid9IFxuICAgICAgICAgICAgLz5cbiAgICAgICAgICB9XG4gICAgICAgICAgYWN0aW9ucz17XG4gICAgICAgICAgICA8QWN0aW9uUGFuZWw+XG4gICAgICAgICAgICAgIDxBY3Rpb24uUHVzaFxuICAgICAgICAgICAgICAgIHRpdGxlPVwiUHJvY2VzcyB3aXRoIFBhdHRlcm5cIlxuICAgICAgICAgICAgICAgIHRhcmdldD17XG4gICAgICAgICAgICAgICAgICA8Rm9ybSBhY3Rpb25zPXtcbiAgICAgICAgICAgICAgICAgICAgPEFjdGlvblBhbmVsPlxuICAgICAgICAgICAgICAgICAgICAgIDxBY3Rpb24uU3VibWl0Rm9ybSBcbiAgICAgICAgICAgICAgICAgICAgICAgIHRpdGxlPVwiUHJvY2Vzc1wiIFxuICAgICAgICAgICAgICAgICAgICAgICAgaWNvbj17SWNvbi5UZXJtaW5hbH0gXG4gICAgICAgICAgICAgICAgICAgICAgICBvblN1Ym1pdD17KHZhbHVlcykgPT4gaGFuZGxlU3VibWl0KHBhdHRlcm4sIHZhbHVlcyl9IFxuICAgICAgICAgICAgICAgICAgICAgIC8+XG4gICAgICAgICAgICAgICAgICAgIDwvQWN0aW9uUGFuZWw+XG4gICAgICAgICAgICAgICAgICB9IGlzTG9hZGluZz17aXNQcm9jZXNzaW5nfT5cbiAgICAgICAgICAgICAgICAgICAge2lucHV0TW9kZSA9PT0gXCJ1cmxcIiAmJiAoXG4gICAgICAgICAgICAgICAgICAgICAgPEZvcm0uVGV4dEZpZWxkIFxuICAgICAgICAgICAgICAgICAgICAgICAgaWQ9XCJ1cmxcIiBcbiAgICAgICAgICAgICAgICAgICAgICAgIHRpdGxlPVwiVVJMXCIgXG4gICAgICAgICAgICAgICAgICAgICAgICBwbGFjZWhvbGRlcj1cIkVudGVyIFVSTCB0byBwcm9jZXNzXCJcbiAgICAgICAgICAgICAgICAgICAgICAvPlxuICAgICAgICAgICAgICAgICAgICApfVxuICAgICAgICAgICAgICAgICAgICB7aW5wdXRNb2RlID09PSBcInlvdXR1YmVcIiAmJiAoXG4gICAgICAgICAgICAgICAgICAgICAgPEZvcm0uVGV4dEZpZWxkIFxuICAgICAgICAgICAgICAgICAgICAgICAgaWQ9XCJ5b3V0dWJlVXJsXCIgXG4gICAgICAgICAgICAgICAgICAgICAgICB0aXRsZT1cIllvdVR1YmUgVVJMXCIgXG4gICAgICAgICAgICAgICAgICAgICAgICBwbGFjZWhvbGRlcj1cIkVudGVyIFlvdVR1YmUgVVJMXCJcbiAgICAgICAgICAgICAgICAgICAgICAvPlxuICAgICAgICAgICAgICAgICAgICApfVxuICAgICAgICAgICAgICAgICAgICA8Rm9ybS5UZXh0RmllbGQgXG4gICAgICAgICAgICAgICAgICAgICAgaWQ9XCJzYXZlRmlsZU5hbWVcIiBcbiAgICAgICAgICAgICAgICAgICAgICB0aXRsZT1cIlNhdmUgQXMgKE9wdGlvbmFsKVwiIFxuICAgICAgICAgICAgICAgICAgICAgIHBsYWNlaG9sZGVyPVwiRW50ZXIgZmlsZW5hbWUgdG8gc2F2ZVwiIFxuICAgICAgICAgICAgICAgICAgICAvPlxuICAgICAgICAgICAgICAgICAgPC9Gb3JtPlxuICAgICAgICAgICAgICAgIH1cbiAgICAgICAgICAgICAgLz5cbiAgICAgICAgICAgIDwvQWN0aW9uUGFuZWw+XG4gICAgICAgICAgfVxuICAgICAgICAvPlxuICAgICAgKSl9XG4gICAgPC9MaXN0PlxuICApO1xufVxuIiwgImltcG9ydCB7IHVzZVN0YXRlIH0gZnJvbSBcInJlYWN0XCI7XG5pbXBvcnQgeyBzaG93VG9hc3QsIFRvYXN0LCBDbGlwYm9hcmQsIGdldFByZWZlcmVuY2VWYWx1ZXMgfSBmcm9tIFwiQHJheWNhc3QvYXBpXCI7XG5pbXBvcnQgeyBleGVjIH0gZnJvbSBcImNoaWxkX3Byb2Nlc3NcIjtcbmltcG9ydCB7IHByb21pc2lmeSB9IGZyb20gXCJ1dGlsXCI7XG5pbXBvcnQgZnMgZnJvbSBcImZzXCI7XG5pbXBvcnQgcGF0aCBmcm9tIFwicGF0aFwiO1xuaW1wb3J0IHsgZmV0Y2hVcmxDb250ZW50IH0gZnJvbSAnLi4vdXRpbHMvdXJsRmV0Y2hlcic7XG5cbmNvbnN0IGV4ZWNBc3luYyA9IHByb21pc2lmeShleGVjKTtcblxuaW50ZXJmYWNlIFBhdHRlcm4ge1xuICBuYW1lOiBzdHJpbmc7XG4gIHBhdGg6IHN0cmluZztcbiAgZGVzY3JpcHRpb24/OiBzdHJpbmc7XG59XG5cbmludGVyZmFjZSBQcmVmZXJlbmNlcyB7XG4gIGZhYnJpY1BhdGg6IHN0cmluZztcbiAgc2F2ZVBhdGg6IHN0cmluZztcbiAgcGF0dGVybnNQYXRoOiBzdHJpbmc7XG4gIHNhdmVUYXJnZXRQYXRoPzogc3RyaW5nO1xuICBtb2RlbD86IHN0cmluZztcbn1cblxuZnVuY3Rpb24gZXhwYW5kVGlsZGUoZmlsZVBhdGg6IHN0cmluZyk6IHN0cmluZyB7XG4gIGlmIChmaWxlUGF0aC5zdGFydHNXaXRoKCd+LycpKSB7XG4gICAgcmV0dXJuIHBhdGguam9pbihwcm9jZXNzLmVudi5IT01FIHx8ICcnLCBmaWxlUGF0aC5zbGljZSgyKSk7XG4gIH1cbiAgcmV0dXJuIGZpbGVQYXRoO1xufVxuXG5leHBvcnQgY29uc3QgUEFUSFMgPSAoKCkgPT4ge1xuICBjb25zdCBwcmVmZXJlbmNlcyA9IGdldFByZWZlcmVuY2VWYWx1ZXM8UHJlZmVyZW5jZXM+KCk7XG4gIHJldHVybiB7XG4gICAgRkFCUklDOiBleHBhbmRUaWxkZShwcmVmZXJlbmNlcy5mYWJyaWNQYXRoIHx8IHBhdGguam9pbihwcm9jZXNzLmVudi5IT01FIHx8IFwiXCIsIFwiZ28vYmluL2ZhYnJpY1wiKSksXG4gICAgU0FWRTogZXhwYW5kVGlsZGUocHJlZmVyZW5jZXMuc2F2ZVBhdGggfHwgcGF0aC5qb2luKHByb2Nlc3MuZW52LkhPTUUgfHwgXCJcIiwgXCIubG9jYWwvYmluL3NhdmVcIikpLFxuICAgIFBBVFRFUk5TOiBleHBhbmRUaWxkZShwcmVmZXJlbmNlcy5wYXR0ZXJuc1BhdGggfHwgcGF0aC5qb2luKHByb2Nlc3MuZW52LkhPTUUgfHwgXCJcIiwgXCIuY29uZmlnL2ZhYnJpYy9wYXR0ZXJuc1wiKSksXG4gICAgU0FWRV9UQVJHRVQ6IHByZWZlcmVuY2VzLnNhdmVUYXJnZXRQYXRoID8gZXhwYW5kVGlsZGUocHJlZmVyZW5jZXMuc2F2ZVRhcmdldFBhdGgpIDogdW5kZWZpbmVkLFxuICAgIE1PREVMOiBwcmVmZXJlbmNlcy5tb2RlbCB8fCB1bmRlZmluZWRcbiAgfSBhcyBjb25zdDtcbn0pKCk7XG5cbmNvbnN0IGdldFBhdHRlcm5EZXNjcmlwdGlvbiA9IGFzeW5jIChwYXR0ZXJuTmFtZTogc3RyaW5nKTogUHJvbWlzZTxzdHJpbmc+ID0+IHtcbiAgdHJ5IHtcbiAgICBjb25zdCBzeXN0ZW1QYXRoID0gcGF0aC5qb2luKFBBVEhTLlBBVFRFUk5TLCBwYXR0ZXJuTmFtZSwgJ3N5c3RlbS5tZCcpO1xuICAgIGNvbnN0IGNvbnRlbnQgPSBhd2FpdCBmcy5wcm9taXNlcy5yZWFkRmlsZShzeXN0ZW1QYXRoLCAndXRmLTgnKTtcbiAgICByZXR1cm4gY29udGVudC50cmltKCk7XG4gIH0gY2F0Y2ggKGVycm9yKSB7XG4gICAgcmV0dXJuICcnOyAvLyBSZXR1cm4gZW1wdHkgc3RyaW5nIGlmIHN5c3RlbS5tZCBkb2Vzbid0IGV4aXN0XG4gIH1cbn07XG5cbmV4cG9ydCBmdW5jdGlvbiB1c2VGYWJyaWNQcm9jZXNzb3IoKSB7XG4gIGNvbnN0IFtpc1Byb2Nlc3NpbmcsIHNldElzUHJvY2Vzc2luZ10gPSB1c2VTdGF0ZShmYWxzZSk7XG5cbiAgY29uc3QgY3JlYXRlVGVtcEZpbGUgPSBhc3luYyAoY29udGVudDogc3RyaW5nKTogUHJvbWlzZTxzdHJpbmc+ID0+IHtcbiAgICBjb25zdCB0ZW1wRmlsZSA9IHBhdGguam9pbihwcm9jZXNzLmVudi5UTVBESVIgfHwgXCIvdG1wXCIsIGByYXljYXN0LWZhYnJpYy0ke0RhdGUubm93KCl9LnR4dGApO1xuICAgIGF3YWl0IGZzLnByb21pc2VzLndyaXRlRmlsZSh0ZW1wRmlsZSwgY29udGVudCk7XG4gICAgcmV0dXJuIHRlbXBGaWxlO1xuICB9O1xuXG4gIGNvbnN0IGNsZWFudXBUZW1wRmlsZSA9IGFzeW5jICh0ZW1wRmlsZTogc3RyaW5nKSA9PiB7XG4gICAgdHJ5IHtcbiAgICAgIGF3YWl0IGZzLnByb21pc2VzLnVubGluayh0ZW1wRmlsZSk7XG4gICAgfSBjYXRjaCAoZXJyb3IpIHtcbiAgICAgIGNvbnNvbGUuZXJyb3IoJ0Vycm9yIGNsZWFuaW5nIHVwIHRlbXAgZmlsZTonLCBlcnJvcik7XG4gICAgfVxuICB9O1xuXG4gIGNvbnN0IGV4ZWN1dGVDb21tYW5kID0gYXN5bmMgKGNvbW1hbmQ6IHN0cmluZykgPT4ge1xuICAgIHJldHVybiBleGVjQXN5bmMoY29tbWFuZCwge1xuICAgICAgZW52OiB7XG4gICAgICAgIC4uLnByb2Nlc3MuZW52LFxuICAgICAgICBQQVRIOiBgL3Vzci9sb2NhbC9iaW46L3Vzci9iaW46L2JpbjovdXNyL3NiaW46L3NiaW46JHtwcm9jZXNzLmVudi5IT01FfS9nby9iaW46JHtwcm9jZXNzLmVudi5IT01FfS8ubG9jYWwvYmluOiR7cHJvY2Vzcy5lbnYuUEFUSCB8fCBcIlwifWAsXG4gICAgICB9LFxuICAgICAgc2hlbGw6ICcvYmluL2Jhc2gnXG4gICAgfSk7XG4gIH07XG5cbiAgY29uc3QgcHJvY2Vzc0NvbnRlbnQgPSBhc3luYyAocGF0dGVybjogc3RyaW5nLCBpbnB1dDogc3RyaW5nLCBzYXZlRmlsZU5hbWU/OiBzdHJpbmcpID0+IHtcbiAgICBzZXRJc1Byb2Nlc3NpbmcodHJ1ZSk7XG4gICAgdHJ5IHtcbiAgICAgIGNvbnN0IGZhYnJpY0NtZCA9IGAke1BBVEhTLkZBQlJJQ30gLS1wYXR0ZXJuICR7cGF0dGVybn0ke1BBVEhTLk1PREVMID8gYCAtbSBcIiR7UEFUSFMuTU9ERUx9XCJgIDogJyd9YDtcbiAgICAgIFxuICAgICAgbGV0IGNvbW1hbmQ7XG4gICAgICBpZiAoaW5wdXQuc3RhcnRzV2l0aCgneXQgLS10cmFuc2NyaXB0ICcpKSB7XG4gICAgICAgIGNvbW1hbmQgPSBgJHtpbnB1dH0gfCAke2ZhYnJpY0NtZH1gO1xuICAgICAgfSBlbHNlIGlmIChpbnB1dC5zdGFydHNXaXRoKCctdSAnKSkge1xuICAgICAgICBjb25zdCB1cmwgPSBpbnB1dC5zbGljZSgzKTtcbiAgICAgICAgY29uc3QgY29udGVudCA9IGF3YWl0IGZldGNoVXJsQ29udGVudCh1cmwpO1xuICAgICAgICBjb25zdCB0ZW1wRmlsZSA9IGF3YWl0IGNyZWF0ZVRlbXBGaWxlKGNvbnRlbnQpO1xuICAgICAgICBcbiAgICAgICAgdHJ5IHtcbiAgICAgICAgICBjb21tYW5kID0gYGNhdCBcIiR7dGVtcEZpbGV9XCIgfCAke2ZhYnJpY0NtZH1gO1xuICAgICAgICAgIGNvbnN0IHsgc3Rkb3V0IH0gPSBhd2FpdCBleGVjdXRlQ29tbWFuZChjb21tYW5kKTtcbiAgICAgICAgICBhd2FpdCBjbGVhbnVwVGVtcEZpbGUodGVtcEZpbGUpO1xuICAgICAgICAgIHJldHVybiBzdGRvdXQ7XG4gICAgICAgIH0gY2F0Y2ggKGVycm9yKSB7XG4gICAgICAgICAgYXdhaXQgY2xlYW51cFRlbXBGaWxlKHRlbXBGaWxlKTtcbiAgICAgICAgICB0aHJvdyBlcnJvcjtcbiAgICAgICAgfVxuICAgICAgfSBlbHNlIHtcbiAgICAgICAgY29tbWFuZCA9IGBjYXQgXCIke2F3YWl0IGNyZWF0ZVRlbXBGaWxlKGlucHV0KX1cIiB8ICR7ZmFicmljQ21kfWA7XG4gICAgICB9XG5cbiAgICAgIGNvbnNvbGUubG9nKGBFeGVjdXRpbmcgY29tbWFuZDogJHtjb21tYW5kfWApO1xuICAgICAgY29uc3QgeyBzdGRvdXQ6IG91dHB1dCwgc3RkZXJyOiBlcnJvciB9ID0gYXdhaXQgZXhlY3V0ZUNvbW1hbmQoY29tbWFuZCk7XG4gICAgICBjb25zb2xlLmxvZyhgT3V0cHV0OiAke291dHB1dH1gKTtcbiAgICAgIGNvbnNvbGUubG9nKGBFcnJvcjogJHtlcnJvcn1gKTtcbiAgICAgIFxuICAgICAgaWYgKGVycm9yKSB7XG4gICAgICAgIHRocm93IG5ldyBFcnJvcihgRmFicmljIGVycm9yOiAke2Vycm9yfWApO1xuICAgICAgfVxuXG4gICAgICBpZiAoc2F2ZUZpbGVOYW1lKSB7XG4gICAgICAgIGF3YWl0IHNhdmVPdXRwdXQob3V0cHV0LCBzYXZlRmlsZU5hbWUpO1xuICAgICAgfVxuXG4gICAgICByZXR1cm4gb3V0cHV0O1xuICAgIH0gZmluYWxseSB7XG4gICAgICBzZXRJc1Byb2Nlc3NpbmcoZmFsc2UpO1xuICAgIH1cbiAgfTtcblxuICBjb25zdCBzYXZlT3V0cHV0ID0gYXN5bmMgKGNvbnRlbnQ6IHN0cmluZywgZmlsZU5hbWU6IHN0cmluZykgPT4ge1xuICAgIGNvbnN0IHRlbXBGaWxlID0gYXdhaXQgY3JlYXRlVGVtcEZpbGUoY29udGVudCk7XG4gICAgXG4gICAgLy8gQnVpbGQgc2F2ZSBjb21tYW5kIGNvbmRpdGlvbmFsbHlcbiAgICBjb25zdCBzYXZlQ29tbWFuZCA9IFBBVEhTLlNBVkVfVEFSR0VUIFxuICAgICAgPyBgY2F0IFwiJHt0ZW1wRmlsZX1cIiB8ICR7UEFUSFMuU0FWRX0gLWQgXCIke1BBVEhTLlNBVkVfVEFSR0VUfVwiIFwiJHtmaWxlTmFtZX1cImBcbiAgICAgIDogYGNhdCBcIiR7dGVtcEZpbGV9XCIgfCAke1BBVEhTLlNBVkV9IFwiJHtmaWxlTmFtZX1cImA7XG4gICAgXG4gICAgYXdhaXQgZXhlY3V0ZUNvbW1hbmQoc2F2ZUNvbW1hbmQpO1xuICAgIFxuICAgIC8vIE9ubHkgYXR0ZW1wdCB0byB2ZXJpZnkgdGhlIGZpbGUgaWYgd2Uga25vdyB3aGVyZSBpdCB3YXMgc2F2ZWRcbiAgICBpZiAoUEFUSFMuU0FWRV9UQVJHRVQpIHtcbiAgICAgIGNvbnN0IGN1cnJlbnREYXRlID0gbmV3IERhdGUoKS50b0lTT1N0cmluZygpLnNwbGl0KCdUJylbMF07XG4gICAgICBjb25zdCBzYXZlZEZpbGUgPSBwYXRoLmpvaW4oUEFUSFMuU0FWRV9UQVJHRVQsIGAke2N1cnJlbnREYXRlfS0ke2ZpbGVOYW1lfS5tZGApO1xuICAgICAgXG4gICAgICBjb25zdCBmaWxlRXhpc3RzID0gYXdhaXQgZnMucHJvbWlzZXMuYWNjZXNzKHNhdmVkRmlsZSkudGhlbigoKSA9PiB0cnVlKS5jYXRjaCgoKSA9PiBmYWxzZSk7XG4gICAgICBpZiAoIWZpbGVFeGlzdHMpIHRocm93IG5ldyBFcnJvcihgRmlsZSBub3Qgc2F2ZWQgYXQ6ICR7c2F2ZWRGaWxlfWApO1xuICAgIH1cblxuICAgIGF3YWl0IHNob3dUb2FzdCh7XG4gICAgICBzdHlsZTogVG9hc3QuU3R5bGUuU3VjY2VzcyxcbiAgICAgIHRpdGxlOiBcIlN1Y2Nlc3NcIixcbiAgICAgIG1lc3NhZ2U6IGBGaWxlIHNhdmVkIGFzOiAke2ZpbGVOYW1lfWBcbiAgICB9KTtcbiAgfTtcblxuICBjb25zdCBsb2FkUGF0dGVybnMgPSBhc3luYyAoKTogUHJvbWlzZTxQYXR0ZXJuW10+ID0+IHtcbiAgICBjb25zdCBmaWxlcyA9IGF3YWl0IGZzLnByb21pc2VzLnJlYWRkaXIoUEFUSFMuUEFUVEVSTlMpO1xuICAgIGNvbnN0IHBhdHRlcm5zID0gYXdhaXQgUHJvbWlzZS5hbGwoXG4gICAgICBmaWxlc1xuICAgICAgICAuZmlsdGVyKGZpbGUgPT4gXG4gICAgICAgICAgZmlsZSAhPT0gJy5EU19TdG9yZScgJiYgXG4gICAgICAgICAgZmlsZSAhPT0gJ3JheWNhc3QnICYmIFxuICAgICAgICAgICFmaWxlLnN0YXJ0c1dpdGgoJy4nKVxuICAgICAgICApXG4gICAgICAgIC5tYXAoYXN5bmMgKGZpbGUpID0+ICh7XG4gICAgICAgICAgbmFtZTogcGF0aC5iYXNlbmFtZShmaWxlLCBwYXRoLmV4dG5hbWUoZmlsZSkpLFxuICAgICAgICAgIHBhdGg6IHBhdGguam9pbihQQVRIUy5QQVRURVJOUywgZmlsZSksXG4gICAgICAgICAgZGVzY3JpcHRpb246IGF3YWl0IGdldFBhdHRlcm5EZXNjcmlwdGlvbihmaWxlKVxuICAgICAgICB9KSlcbiAgICApO1xuICAgIHJldHVybiBwYXR0ZXJucztcbiAgfTtcblxuICByZXR1cm4geyBwcm9jZXNzQ29udGVudCwgaXNQcm9jZXNzaW5nLCBsb2FkUGF0dGVybnMgfTtcbn1cbiIsICJpbXBvcnQgeyBleGVjIH0gZnJvbSAnY2hpbGRfcHJvY2Vzcyc7XG5pbXBvcnQgeyBwcm9taXNpZnkgfSBmcm9tICd1dGlsJztcblxuY29uc3QgZXhlY0FzeW5jID0gcHJvbWlzaWZ5KGV4ZWMpO1xuXG5leHBvcnQgYXN5bmMgZnVuY3Rpb24gZmV0Y2hVcmxDb250ZW50KHVybDogc3RyaW5nKTogUHJvbWlzZTxzdHJpbmc+IHtcbiAgLy8gRmlyc3QsIGNoZWNrIHRoZSBjb250ZW50IHR5cGVcbiAgY29uc3QgaGVhZENvbW1hbmQgPSBgY3VybCAtSSAtTCAtcyBcIiR7dXJsfVwiYDtcbiAgdHJ5IHtcbiAgICBjb25zdCB7IHN0ZG91dDogaGVhZGVycyB9ID0gYXdhaXQgZXhlY0FzeW5jKGhlYWRDb21tYW5kKTtcbiAgICBjb25zdCBjb250ZW50VHlwZSA9IGhlYWRlcnMudG9Mb3dlckNhc2UoKTtcbiAgICBcbiAgICBpZiAoaGVhZGVycy50b0xvd2VyQ2FzZSgpLmluY2x1ZGVzKCdjb250ZW50LXR5cGU6IGFwcGxpY2F0aW9uL3BkZicpKSB7XG4gICAgICB0cnkge1xuICAgICAgICBjb25zdCBqaW5hVXJsID0gYGh0dHBzOi8vci5qaW5hLmFpLyR7ZW5jb2RlVVJJQ29tcG9uZW50KHVybCl9YDtcbiAgICAgICAgY29uc3QgeyBzdGRvdXQgfSA9IGF3YWl0IGV4ZWNBc3luYyhgY3VybCAtTCAtcyBcIiR7amluYVVybH1cImApO1xuICAgICAgICByZXR1cm4gc3Rkb3V0O1xuICAgICAgfSBjYXRjaCAocGRmRXJyb3IpIHtcbiAgICAgICAgdGhyb3cgbmV3IEVycm9yKGBGYWlsZWQgdG8gcHJvY2VzcyBQREY6ICR7cGRmRXJyb3J9LiBUaGUgci5qaW5hLmFpIHNlcnZpY2UgbWlnaHQgYmUgdW5hdmFpbGFibGUuYCk7XG4gICAgICB9XG4gICAgfVxuICAgIFxuICAgIC8vIEZvciByZWd1bGFyIHdlYiBwYWdlc1xuICAgIGNvbnN0IHsgc3Rkb3V0IH0gPSBhd2FpdCBleGVjQXN5bmMoYGN1cmwgLUwgLXMgLUEgXCJNb3ppbGxhLzUuMFwiIFwiJHt1cmx9XCJgKTtcbiAgICBpZiAoIXN0ZG91dCkge1xuICAgICAgdGhyb3cgbmV3IEVycm9yKCdObyBjb250ZW50IGF2YWlsYWJsZSBmcm9tIFVSTCcpO1xuICAgIH1cbiAgICByZXR1cm4gc3Rkb3V0O1xuICB9IGNhdGNoIChlcnJvcikge1xuICAgIHRocm93IG5ldyBFcnJvcihgRmFpbGVkIHRvIGZldGNoIFVSTDogJHtlcnJvcn1gKTtcbiAgfVxufVxuXG4vLyBPcHRpb25hbDogQWRkIHRpbWVvdXQgZm9yIGJvdGggcmVndWxhciBhbmQgUERGIHJlcXVlc3RzXG5leHBvcnQgYXN5bmMgZnVuY3Rpb24gZmV0Y2hVcmxDb250ZW50V2l0aFRpbWVvdXQodXJsOiBzdHJpbmcsIHRpbWVvdXRTZWNvbmRzOiBudW1iZXIgPSAzMCk6IFByb21pc2U8c3RyaW5nPiB7XG4gIGNvbnN0IGNvbW1hbmQgPSBgY3VybCAtTCAtcyAtLW1heC10aW1lICR7dGltZW91dFNlY29uZHN9IFwiJHt1cmx9XCJgO1xuICB0cnkge1xuICAgIGNvbnN0IHsgc3Rkb3V0IH0gPSBhd2FpdCBleGVjQXN5bmMoY29tbWFuZCk7XG4gICAgcmV0dXJuIHN0ZG91dDtcbiAgfSBjYXRjaCAoZXJyb3IpIHtcbiAgICB0aHJvdyBuZXcgRXJyb3IoYFJlcXVlc3QgdGltZWQgb3V0IG9yIGZhaWxlZDogJHtlcnJvcn1gKTtcbiAgfVxufSAiXSwKICAibWFwcGluZ3MiOiAiOzs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7QUFBQTtBQUFBO0FBQUE7QUFBQTtBQUFBO0FBQUEsSUFBQUEsY0FBMkY7QUFDM0YsSUFB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
