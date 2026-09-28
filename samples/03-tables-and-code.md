# 📊 Tables & Syntax Highlighting Benchmark

This test file is designed to evaluate table rendering, horizontal scrolling, column alignments, and code highlighting across different programming languages. TEST SAVING THIS STUFF

---

## 1. Complex Multi-Column Data Table

| API Endpoint | HTTP Method | Auth Required | Rate Limit | Response Format | Example Payload |
| :--- | :---: | :---: | ---: | :--- | :--- |
| `/api/v1/documents` | `GET` | ✅ Bearer Token | 1,000 / hr | `application/json` | `{"count": 42}` |
| `/api/v1/documents` | `POST` | ✅ Bearer Token | 200 / hr | `application/json` | `{"title": "Draft"}` |
| `/api/v1/documents/:id` | `PUT` | ✅ Bearer Token | 500 / hr | `application/json` | `{"content": "..."}` |
| `/api/v1/documents/:id` | `DELETE` | 🔒 Admin Only | 50 / hr | `application/json` | `{"deleted": true}` |
| `/health` | `GET` | ❌ Public | Unlimited | `text/plain` | `OK 200` |

---

## 2. Table with Formatted Markdown Inside Cells

| Format Feature | Syntax Pattern | Rendered Output | Use Case |
| :--- | :--- | :--- | :--- |
| **Bold Emphasis** | `**text**` | **Important** | Key terms & warnings |
| *Italic Emphasis* | `*text*` | *Subtle* | Book titles, citations |
| ~~Strikethrough~~ | `~~text~~` | ~~Deprecated~~ | Completed or removed items |
| [Hyperlink](https://github.com) | `[title](url)` | [GitHub](https://github.com) | External documentation |
| `Inline Code` | `` `code` `` | `localStorage.getItem()` | Variable & function names |

---

## 3. Programming Languages Syntax Showcase

### Python (Async Web Request)
```python
import asyncio
import aiohttp

async def fetch_document(url: str) -> dict:
    async with aiohttp.ClientSession() as session:
        async with session.get(url) as response:
            response.raise_for_status()
            return await response.json()

if __name__ == "__main__":
    data = asyncio.run(fetch_document("https://api.github.com/zen"))
    print(f"Server response: {data}")
```

### TypeScript / JavaScript (Type Safety)
```typescript
interface DocumentMetadata {
  readonly id: string;
  title: string;
  createdAt: Date;
  tags: string[];
  isArchived: boolean;
}

export function filterActiveDocs(docs: DocumentMetadata[]): DocumentMetadata[] {
  return docs
    .filter(doc => !doc.isArchived)
    .sort((a, b) => b.createdAt.getTime() - a.createdAt.getTime());
}
```

### Go (Concurrent Pipeline)
```go
package main

import (
	"fmt"
	"sync"
)

func processTask(id int, wg *sync.WaitGroup, out chan<- string) {
	defer wg.Done()
	out <- fmt.Sprintf("Worker %d completed task", id)
}

func main() {
	var wg sync.WaitGroup
	results := make(chan string, 3)

	for i := 1; i <= 3; i++ {
		wg.Add(1)
		go processTask(i, &wg, results)
	}

	wg.Wait()
	close(results)

	for res := range results {
		fmt.Println(res)
	}
}
```

### SQL (Database Analytics Query)
```sql
SELECT 
    d.category,
    COUNT(d.id) AS total_documents,
    AVG(LENGTH(d.content)) AS avg_length,
    MAX(d.updated_at) AS last_modified
FROM documents d
WHERE d.status = 'published'
  AND d.created_at >= '2026-01-01'
GROUP BY d.category
HAVING COUNT(d.id) > 5
ORDER BY total_documents DESC;
```

### Bash / Shell Scripting
```bash
#!/usr/bin/env bash
set -euo pipefail

WORKSPACE_DIR="${1:-$HOME/markdown-viewer}"
echo "Inspecting workspace at: ${WORKSPACE_DIR}"

if [[ -d "${WORKSPACE_DIR}" ]]; then
  echo "Found $(find "${WORKSPACE_DIR}" -type f -name "*.md" | wc -l) markdown files."
else
  echo "Error: Directory does not exist!" >&2
  exit 1
fi
```
          