load("//protobuf_js:protobuf_js_repo.bzl", "protobuf_js_repo")


def protobuf_js_dependencies():
    protobuf_js_repo(
        name = "protobuf_js",
        version = "3.21.4",
    )