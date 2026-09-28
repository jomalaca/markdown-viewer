# 📐 Advanced Math & Mermaid Diagrams Benchmark

This file stress-tests advanced mathematical equations via KaTeX and various Mermaid diagram types.

---

## Part 1: Advanced KaTeX Mathematics

### 1. Maxwell's Equations of Electrodynamics

$$
\begin{aligned}
\nabla \cdot \mathbf{E} &= \frac{\rho}{\varepsilon_0} && \text{(Gauss's Law)} \\
\nabla \cdot \mathbf{B} &= 0 && \text{(Gauss's Law for Magnetism)} \\
\nabla \times \mathbf{E} &= -\frac{\partial \mathbf{B}}{\partial t} && \text{(Faraday's Law of Induction)} \\
\nabla \times \mathbf{B} &= \mu_0 \mathbf{J} + \mu_0 \varepsilon_0 \frac{\partial \mathbf{E}}{\partial t} && \text{(Ampère-Maxwell Law)}
\end{aligned}
$$

### 2. Piecewise Defined Function

$$
f(x) = \begin{cases}
x^2 \sin\left(\frac{1}{x}\right) & \text{if } x \neq 0 \\
0 & \text{if } x = 0
\end{cases}
$$

### 3. Greek Letters & Series Expansions

Taylor expansion of $\cos(x)$ around $a = 0$:

$$
\cos(x) = \sum_{k=0}^{\infty} \frac{(-1)^k}{(2k)!} x^{2k} = 1 - \frac{x^2}{2!} + \frac{x^4}{4!} - \frac{x^6}{6!} + \cdots
$$

---

## Part 2: Diverse Mermaid Diagrams

### 1. State Diagram (Lifecycle of a Document)

```mermaid
stateDiagram-v2
    [*] --> NewDocument
    NewDocument --> Drafting : Typing
    Drafting --> AutoSaved : Idle (300ms)
    AutoSaved --> Drafting : Edit
    AutoSaved --> StandaloneHTML : Export
    AutoSaved --> CleanPDF : Print / PDF
    AutoSaved --> Closed : Close Tab
    Closed --> [*]
```

### 2. Class Diagram (Object-Oriented Design)

```mermaid
classDiagram
    class DocumentWorkspace {
        +List~Tab~ tabs
        +String activeTabId
        +Boolean syncScroll
        +createTab(title, content)
        +setActiveTab(id)
        +closeTab(id)
    }

    class Tab {
        +String id
        +String title
        +String content
        +Boolean isModified
        +getWordCount() int
    }

    class ExportPipeline {
        +downloadMarkdown(tab)
        +exportHTML(tab)
        +triggerPrint()
    }

    DocumentWorkspace "1" *-- "many" Tab : contains
    DocumentWorkspace ..> ExportPipeline : invokes
```

### 3. Pie Chart (Time Allocation)

```mermaid
pie title Markdown Editor Usage Distribution
    "Writing & Drafting" : 45
    "Live Preview Review" : 25
    "Diagram Authoring" : 15
    "Exporting & Sharing" : 15
```

### 4. Git Graph (Branching & Releases)

```mermaid
gitGraph
    commit id: "v1.0.0"
    commit id: "Add GFM"
    branch feature/math
    checkout feature/math
    commit id: "Add KaTeX"
    commit id: "Inline & Display Math"
    checkout main
    merge feature/math id: "Merge Math Support"
    branch feature/mermaid
    checkout feature/mermaid
    commit id: "Add Mermaid diagrams"
    checkout main
    merge feature/mermaid id: "v1.1.0 Release"
    commit id: "Deploy local-first"
```
