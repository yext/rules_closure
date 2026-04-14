# Copyright 2026 The Closure Rules Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""Downloads a platform-specific protoc binary."""

def _get_platform(repository_ctx):
    os_name = repository_ctx.os.name.lower()
    arch = repository_ctx.os.arch.lower()

    if os_name.startswith("mac os"):
        if arch in ("aarch64", "x86_64"):
            return "osx-universal_binary"
        fail("Unsupported architecture '{}' for macOS.".format(arch))

    if os_name == "linux":
        if arch in ("amd64", "x86_64"):
            return "linux-x86_64"
        fail("Unsupported architecture '{}' for Linux.".format(arch))

    fail("Unsupported operating system '{}'.".format(os_name))

def _protoc_repo_impl(repository_ctx):
    platform = _get_platform(repository_ctx)
    urls = repository_ctx.attr.urls.get(platform)
    sha256 = repository_ctx.attr.sha256s.get(platform)

    if not urls:
        fail("No protoc URLs configured for platform '{}'.".format(platform))
    if not sha256:
        fail("No protoc SHA256 configured for platform '{}'.".format(platform))

    repository_ctx.download_and_extract(urls, sha256 = sha256)
    repository_ctx.file("BUILD", """
genrule(
    name = "protoc",
    srcs = ["bin/protoc"],
    outs = ["protoc_bin"],
    cmd = "cp $(location bin/protoc) $@ && chmod +x $@",
    executable = True,
    visibility = ["//visibility:public"],
)
""")

protoc_repo = repository_rule(
    implementation = _protoc_repo_impl,
    attrs = {
        "urls": attr.string_list_dict(mandatory = True),
        "sha256s": attr.string_dict(mandatory = True),
    },
)
