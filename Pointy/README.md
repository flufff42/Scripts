# Pointy

Highlights a point of interest in a file using a pointer.

## Usage

Run this using [Marathon](https://github.com/johnsundell/marathon):

```shell
$ marathon run pointy help pointer                                                                         
Outputs a pointer to the specified offset in the given file

[--offset (integer)]
	The offset for the pointer to be output

[--context (integer)]
	Lines of context to show around the line pointed at

[--pointer (string)]
	Character to use to point at offset

(string)
	the file path containing the offset to point at
```

## Example

```shell
$ marathon run pointy.swift pointer --offset 18149 --context 3 ../../Alamofire/Source/MultipartFormData.swift
        var headerText = ""

        for (key, value) in bodyPart.headers {
            headerText += "\(key): \(value)\(EncodingCharacters.crlf)"
                      ^
        }
        headerText += EncodingCharacters.crlf
        return headerText.data(using: String.Encoding.utf8, allowLossyConversion: false)!
```