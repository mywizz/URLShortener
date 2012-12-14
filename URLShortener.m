// URLShortener.m
//
// Copyright (c) 2012 Yunseok Kim (http://mywizz.me/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "URLShortener.h"
#import "AFNetworking.h"
#import "NSString+URLEncoding.h"

@implementation URLShortener

// ---------------------------------------------------------------------
#pragma mark -

+ (void)shorten:(NSString *)url
          using:(URLShortenerService)service
        handler:(void(^)(id result, NSError *error))handler
{
	NSDictionary *inputResult = [NSDictionary dictionaryWithObjectsAndKeys:url, @"originalURL", url, @"shortURL", nil];
	
	if (service == URLShortenerServiceIsgd)
	{
		NSString *apiURL = [NSString stringWithFormat:@"http://is.gd/create.php?format=simple&url=%@", [url URLEncodedString]];
		NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:apiURL]];
		AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
		
		[operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
			
			NSString *shortURL = operation.responseString;
			if (shortURL.length)
			{
				NSDictionary *result = [NSDictionary dictionaryWithObjectsAndKeys:url, @"originalURL", shortURL, @"shortURL", nil];
				handler(result, nil);
				return;
			}
			
			handler(inputResult, nil);
			
		} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			
			handler(nil, error);
			
		}];
		
		[operation start];
	}
	else if (service == URLShortenerServiceGoogle)
	{
		// Goo.gl throws error when http://goo.gl/.. given
		if ([[url lowercaseString] hasPrefix:@"http://goo.gl"])
		{
			handler(inputResult, nil);
			return;
		}
		
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://www.googleapis.com/urlshortener/v1/url"]];
		NSData *body = [[[NSString stringWithFormat:@"{\"longUrl\": \"%@\"}", url] dataUsingEncoding:NSUTF8StringEncoding] mutableCopy];
		[request setHTTPMethod:@"POST"];
		[request setHTTPBody:body];
		[request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
		
		AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
			
			NSDictionary *err = [JSON objectForKey:@"error"];
			if (err)
			{
				NSError *parseError = [NSError errorWithDomain:@"com.google.Googl" code:[[err objectForKey:@"code"] integerValue] userInfo:[NSDictionary dictionaryWithObject:[err objectForKey:@"message"] forKey:NSLocalizedDescriptionKey]];
				handler(nil, parseError);
				return;
			}
			
			NSString *shortURL = [JSON objectForKey:@"id"];
			NSDictionary *result = [NSDictionary dictionaryWithObjectsAndKeys:url, @"originalURL", shortURL, @"shortURL", nil];
			handler(result, nil);
			
		} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
			
			handler(nil, error);
			
		}];
		
		[operation start];
	}
	else
	{
		handler(inputResult, nil);
	}
}

+ (void)shorten:(NSString *)url
          using:(URLShortenerService)service
       username:(NSString *)username
            key:(NSString *)key
        handler:(void (^)(id, NSError *))handler
{
	NSDictionary *inputResult = [NSDictionary dictionaryWithObjectsAndKeys:url, @"originalURL", url, @"shortURL", nil];

	if (service != URLShortenerServiceJmp && service != URLShortenerServiceBitly)
	{
		handler(inputResult, nil);
		return;
	}

	NSString *apiURL = [NSString stringWithFormat:@"http://api.bit.ly/v3/shorten?format=txt&longurl=%@&apikey=%@&login=%@&domain=%@",
						[url URLEncodedString], key, username, (service == URLShortenerServiceJmp ? @"j.mp" : @"bit.ly")];
	
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:apiURL]];
	AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
	[operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {

		NSString *shortURL = [operation.responseString stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
		if (shortURL.length)
		{
			NSDictionary *result = [NSDictionary dictionaryWithObjectsAndKeys:url, @"originalURL", shortURL, @"shortURL", nil];
			handler(result, nil);
			return;
		}
		
		handler(inputResult, nil);
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		
		handler(nil, error);
		
	}];
	
	[operation start];
}

@end