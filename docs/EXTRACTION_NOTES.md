# Extraction Notes

The uploaded `.rbxl` uses Roblox's binary place format. The extractor decoded the binary chunk structure, decompressed Zstandard/LZ4 chunks, reconstructed Instance referents and parent relationships, then read `Name`, `Source`, `Disabled`, and `RunContext` properties for Script-like Instances.

No Roblox script source was executed during extraction.
