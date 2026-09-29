# Image Rendering Benchmark

This sample document verifies image rendering across relative paths, raw HTML tags, and remote web sources.

---

## 1. Relative Markdown Image

Below is a relative image pointing to `../macos/resources/app_icon.png`:

![Markdown Viewer App Icon](../macos/resources/app_icon.png)

---

## 2. Raw HTML Image Tag

Below is a raw HTML `<img>` tag with custom attributes:

<p align="center">
  <img src="../macos/resources/app_icon.png" width="128" height="128" alt="App Icon Centered" />
  <br>
  <em>Figure 1: App icon rendered via raw HTML with custom width and height.</em>
</p>

---

## 3. Remote Web Image

Below is an image loaded from a public web URL:

![Markdown Logo](https://raw.githubusercontent.com/github/explore/main/topics/markdown/markdown.png)
