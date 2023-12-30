import test from "node:test";
import assert from "node:assert";

const add = (a, b) => a + b;

test("add", (t) => {
      t.test("adds 1 + 2 to equal 3", () => {
    assert.strictEqual(add(1, 2), 3);
  });
});
