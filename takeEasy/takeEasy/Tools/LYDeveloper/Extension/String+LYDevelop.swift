//
//  String+LYDevelop.swift
//  i行销
//
//  Created by Gordon on 2017/6/27.
//  Copyright © 2017年 taikanglife. All rights reserved.
//

import UIKit

extension String {
    
    // MARK: === 字符串添加字间距
    ///  字符串添加字间距（通过转化成AttributedString的方式）
    ///
    /// - Parameter font: 文字字体
    /// - Parameter color: 文字颜色
    /// - Parameter wordSpacing: 文字间距
    ///
    /// - Returns: 带有字体,颜色,间距的AttributedString
    func ly_AttributeStr(font: UIFont, color: UIColor, wordSpacing: Float) -> NSMutableAttributedString {
        
        let attrStr = NSMutableAttributedString.init(string: self)
        guard self.characters.count > 0 else {
            return attrStr
        }
        let range = NSMakeRange(0, attrStr.length)
        attrStr.addAttributes([NSFontAttributeName: font,
            NSForegroundColorAttributeName: color], range: range)
        guard wordSpacing != 0 else {
            return attrStr
        }
        attrStr.addAttribute(NSKernAttributeName, value: wordSpacing, range: NSMakeRange(0, attrStr.length - 1))
        return attrStr
    }
    
    // MARK: === 字符串添加字间距,行间距
    ///  字符串添加字间距,行间距（通过转化成AttributedString的方式）
    ///
    /// - Parameter font: 文字字体
    /// - Parameter color: 文字颜色
    /// - Parameter wordSpacing: 文字间距
    /// - Parameter lineSpacing: 行间距
    /// - Parameter lineAlignment: 文字对齐方式
    ///
    /// - Returns: 带有字体,颜色,间距的AttributedString
    func ly_AttributeStr(font: UIFont, color: UIColor, wordSpacing: Float, lineSpacing:CGFloat, lineAlignment:NSTextAlignment) -> NSMutableAttributedString {
        
        let attr = self.ly_AttributeStr(font: font, color: color, wordSpacing: wordSpacing)
       
        let paragrapnStyle = NSMutableParagraphStyle()
        paragrapnStyle.lineSpacing = CGFloat(lineSpacing)
        paragrapnStyle.alignment = lineAlignment
        attr.addAttribute(NSParagraphStyleAttributeName, value: paragrapnStyle, range: NSMakeRange(0, attr.length))
        return attr
    }
    
    static let regex_手机号 = "^[1][34578][0-9]{9}$"
    static let regex_身份证号 = "^(\\d{14}|\\d{17})(\\d|[xX])$"
    
    // MARK: === 正则校验
    func ly_validWith(regexStr: String) -> Bool {
        let predicate = NSPredicate.init(format: "SELF MATCHES %@", regexStr)
        return predicate.evaluate(with:self)
    }
    func ly_isValidateIDCardNo() -> Bool {
        return self.ly_validWith(regexStr: .regex_身份证号)
    }
    func ly_isValidatePhoneNum() -> Bool {
        return self.ly_validWith(regexStr: .regex_手机号)
    }
    
    // MARK: === MD5
    func md5() -> String {
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = CUnsignedInt(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        CC_MD5(str!, strLen, result)
        let hash = NSMutableString()
        for i in 0 ..< digestLen {
            hash.appendFormat("%02X", result[i])
        }
        result.deinitialize()
        return String(format: hash as String)
    }

}