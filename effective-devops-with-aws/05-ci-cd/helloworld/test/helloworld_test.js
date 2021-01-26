const Browser = require("zombie");
const assert = require("assert");
const app = require("../helloworld");

describe("main page", function () {
  before(function () {
    this.browser = new Browser({ site: "http://localhost:3000" });
  });
  before(function (done) {
    this.browser.visit("/", done);
  });
  it("should say hello world", function () {
    assert.ok(this.browser.success);
    assert.strictEqual(this.browser.text(), "Hello World");
  });
});
