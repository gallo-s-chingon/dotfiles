/// <reference types="@raycast/api">

/* 🚧 🚧 🚧
 * This file is auto-generated from the extension's manifest.
 * Do not modify manually. Instead, update the `package.json` file.
 * 🚧 🚧 🚧 */

/* eslint-disable @typescript-eslint/ban-types */

type ExtensionPreferences = {
  /** Fabric Binary Path - Path to the Fabric binary */
  "fabricPath": string,
  /** Save Binary Path - Path to the Save binary */
  "savePath": string,
  /** Patterns Directory - Path to the Fabric patterns directory */
  "patternsPath": string,
  /** Save Target Directory - Optional: Path where processed files will be saved. If not set, will use the default from your save script configuration. */
  "saveTargetPath": string,
  /** Model Name - Optional: Specify the model to use with Fabric */
  "model": string
}

/** Preferences accessible in all the extension's commands */
declare type Preferences = ExtensionPreferences

declare namespace Preferences {
  /** Preferences accessible in the `fabric-pattern` command */
  export type FabricPattern = ExtensionPreferences & {}
}

declare namespace Arguments {
  /** Arguments passed to the `fabric-pattern` command */
  export type FabricPattern = {}
}

