//
//  TestTags.swift
//  NetworkLayer
//
//  Created by Alex.personal on 30/6/25.
//

import Testing

extension Tag {

    enum Interceptor {
        @Tag static var adapt: Tag
        @Tag static var process: Tag
    }
}
