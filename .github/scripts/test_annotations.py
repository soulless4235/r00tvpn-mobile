"""Turns failed tests from `flutter test --file-reporter json:<file>` into
GitHub annotations and a job summary, which a public repository shows without
signing in (raw logs need an account)."""

import json
import os
import sys

MAX_ANNOTATIONS = 50
MAX_MESSAGE = 1500


def escape(text):
    return text.replace("%", "%25").replace("\r", "").replace("\n", "%0A")


def escape_property(text):
    return escape(text).replace(":", "%3A").replace(",", "%2C")


def main(path):
    suites, tests, errors, failed = {}, {}, {}, []
    with open(path, encoding="utf-8") as report:
        for line in report:
            try:
                event = json.loads(line)
            except ValueError:
                continue
            kind = event.get("type")
            if kind == "suite":
                suites[event["suite"]["id"]] = event["suite"].get("path") or ""
            elif kind == "testStart":
                tests[event["test"]["id"]] = event["test"]
            elif kind == "error":
                errors.setdefault(event["testID"], []).append(event.get("error", ""))
            elif kind == "testDone" and event.get("result") != "success":
                failed.append(event["testID"])

    root = os.getcwd()
    rows = []
    for test_id in failed:
        test = tests.get(test_id, {})
        suite = os.path.relpath(suites.get(test.get("suiteID"), ""), root)
        name = test.get("name") or "(unknown test)"
        message = "\n".join(errors.get(test_id, [])).strip() or "failed"
        rows.append((suite, name, message))

    for suite, name, message in rows[:MAX_ANNOTATIONS]:
        print(
            f"::error file={escape_property(suite)},title={escape_property(name)}::"
            f"{escape(message[:MAX_MESSAGE])}"
        )

    summary = os.environ.get("GITHUB_STEP_SUMMARY")
    if summary:
        with open(summary, "a", encoding="utf-8") as out:
            out.write(f"### Failed tests: {len(rows)}\n\n")
            for suite, name, message in rows:
                out.write(f"- `{suite}`: {name}\n\n")
                out.write("  ```\n")
                for text in message[:MAX_MESSAGE].splitlines():
                    out.write(f"  {text}\n")
                out.write("  ```\n")
    print(f"{len(rows)} failed test(s)")


if __name__ == "__main__":
    main(sys.argv[1])
