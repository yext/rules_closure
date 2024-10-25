def _protobuf_js_repo_impl(ctx):
    version = ctx.attr.version

    arch = get_arch_value(ctx)

    url = "https://github.com/protocolbuffers/protobuf-javascript/releases/download/v{version}/protobuf-javascript-{version}-{arch}.tar.gz".format(
        version=version,
        arch=arch,
    )

    # https://github.com/protocolbuffers/protobuf-javascript/releases/tag/v3.21.4
    sha256s = {
        "osx-aarch_64": "308b3713bc6f2147c8622d0dbb82b2ffcb2e25860c89d763ea00c2d768589989",
        "osx-x86_64": "9bfa23630fb2fd99c0328d247f91a454b4d4a2276dd4953af0a052430554510d",
        "linux-x86_64": "c57ba4130471c642462fcf98c844a3c933f6c4708b9fddc859900fd2a2e72a45",
    }

    sha256 = sha256s.get(arch)
    if not sha256:
        fail("No SHA256 checksum found for arch: {}".format(arch))

    archive = ctx.download_and_extract(url, sha256=sha256)

    bin_dir = ctx.path("bin")
    protoc_gen_js = "{}/protoc-gen-js".format(bin_dir)
    print(protoc_gen_js)

    # Symlink the executable to the repository root
    ctx.symlink(protoc_gen_js, "protoc-gen-js")

    # Create a BUILD file to export the binary
    ctx.file("BUILD", """exports_files(["protoc-gen-js"])""")

def get_arch_value(repository_ctx):
    """Determine the architecture string based on OS and CPU."""
    os_name = repository_ctx.os.name.lower()
    arch = repository_ctx.os.arch.lower()

    if os_name.startswith("mac os"):
        if arch == "aarch64":
            return "osx-aarch_64"
        elif arch == "x86_64":
            return "osx-x86_64"
        else:
            fail("Unsupported architecture '{}' for macOS.".format(arch))
    elif os_name == "linux":
        if arch == "x86_64" or arch == "amd64":
            return "linux-x86_64"
        else:
            fail("Unsupported architecture '{}' for Linux.".format(arch))
    else:
        fail("Unsupported operating system '{}'.".format(os_name))

protobuf_js_repo = repository_rule(
    implementation = _protobuf_js_repo_impl,
    attrs = {
        "version": attr.string(mandatory = True),
    },
)
