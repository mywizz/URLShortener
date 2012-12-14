# URLShortener

URL shortening library for

- goo.gl
- bit.ly
- j.mp
- is.gd

## Requirement

- [AFNetworking](https://github.com/AFNetworking/AFNetworking)
- [NSString+URLEncoding](http://oauth.googlecode.com/svn/code/obj-c/OAuthConsumer/)
- ARC

## Usage

### Goo.gl

	[URLShortener shorten:@"YOUR_LONG_URL" using:URLShortenerServiceGoogle handler:^(id result, NSError *error) {
		if (error)
		{
			// Do something with error
		}
		else
		{
			NSString *originalURL = [result objectForKey:@"originalURL"];
			NSString *shortURL = [result objectForKey:@"shortURL"];
			NSLog(@"%@ => %@", originalURL, shortURL);
		}
	}];
	
### Is.gd

	[URLShortener shorten:@"YOUR_LONG_URL" URLShortenerServiceIsgd handler:^(id result, NSError *error) {
		if (error)
		{
			// Do something with error
		}
		else
		{
			NSString *originalURL = [result objectForKey:@"originalURL"];
			NSString *shortURL = [result objectForKey:@"shortURL"];
			NSLog(@"%@ => %@", originalURL, shortURL);
		}
	}];	
	
	
### Bit.ly
	
	[URLShortener shorten:url using:URLShortenerServiceBitly username:@"YOUR_BITLY_USERNAME" key:@"YOUR_BITLY_API_KEY" handler:^(id result, NSError *error) {
		if (error)
		{
			// Do something with error
		}
		else
		{
			NSString *originalURL = [result objectForKey:@"originalURL"];
			NSString *shortURL = [result objectForKey:@"shortURL"];
			NSLog(@"%@ => %@", originalURL, shortURL);
		}
		
		
### J.mp
	
	[URLShortener shorten:url URLShortenerServiceJmp username:@"YOUR_BITLY_USERNAME" key:@"YOUR_BITLY_API_KEY" handler:^(id result, NSError *error) {
		if (error)
		{
			// Do something with error
		}
		else
		{
			NSString *originalURL = [result objectForKey:@"originalURL"];
			NSString *shortURL = [result objectForKey:@"shortURL"];
			NSLog(@"%@ => %@", originalURL, shortURL);
		}
		
## License

Available under the MIT license.