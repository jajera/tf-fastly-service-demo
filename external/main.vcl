sub vcl_recv {
  #FASTLY recv
  # Restrict access to multiple paths
  if (req.url.path ~ "^/(coastal|metadata/seismic|stationxml)(/|$)") {
    error 403 "Restricted";
  }

  # Restrict unnecessary or bad HTTP methods
  if (req.request != "GET" && req.request != "HEAD" && req.request != "PUT" && req.request != "POST") {
    error 405 "Method Not Allowed";
  }

  set req.http.X-Country-Code = client.geo.country_code;

  return(lookup);
}

sub vcl_error {
  #FASTLY error
  if (obj.status == 403) {
    set obj.http.Content-Type = "text/html";
    synthetic {"<h1>403 Forbidden</h1><p>Access to this resource is forbidden.</p>"};
    return (deliver);
  }

  if (obj.status == 405) {
    set obj.http.Content-Type = "text/html; charset=utf-8";
    set obj.http.WWW-Authenticate = "Basic realm=Secured";
    synthetic {"<?xml version="1.0" encoding="utf-8"?>
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>405 Method Not Allowed</title>
      <style>
        body {
          font-family: Arial, sans-serif;
          background-color: #f4f4f4;
          color: #333;
          margin: 0;
          padding: 0;
          display: flex;
          align-items: center;
          justify-content: center;
          height: 100vh;
        }
        #container {
          background: #fff;
          border: 1px solid #ccc;
          border-radius: 8px;
          box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
          padding: 2em;
          max-width: 600px;
          text-align: center;
        }
        h1 {
          font-size: 2.5em;
          color: #e74c3c;
          margin: 0 0 1em;
        }
        p {
          font-size: 1.2em;
          margin: 0.5em 0;
        }
        a {
          text-decoration: none;
          color: #3498db;
          font-weight: bold;
        }
        a:hover {
          text-decoration: underline;
        }
      </style>
    </head>
    <body>
      <div id="container">
        <h1>405 Method Not Allowed</h1>
        <p>We're sorry, but the method you used is not allowed for this endpoint.</p>
        <p>Please check the request method and try again.</p>
        <p><a href="/">Return to Homepage</a></p>
      </div>
    </body>
    </html>
    "};
    return (deliver);
  }

  if (obj.status == 429) {
    set obj.http.Content-Type = "text/html; charset=utf-8";
    set obj.http.WWW-Authenticate = "Basic realm=Secured";
    synthetic {"<?xml version="1.0" encoding="utf-8"?>
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>429 Too Many Requests</title>
      <style>
        body {
          font-family: Arial, sans-serif;
          background-color: #f8f8f8;
          color: #333;
          margin: 0;
          padding: 0;
          display: flex;
          align-items: center;
          justify-content: center;
          height: 100vh;
        }
        #container {
          background: #fff;
          border: 1px solid #ddd;
          border-radius: 8px;
          box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
          padding: 2em;
          max-width: 600px;
          text-align: center;
        }
        h1 {
          font-size: 2.5em;
          color: #e67e22;
          margin: 0 0 1em;
        }
        p {
          font-size: 1.2em;
          margin: 0.5em 0;
        }
        a {
          text-decoration: none;
          color: #3498db;
          font-weight: bold;
        }
        a:hover {
          text-decoration: underline;
        }
      </style>
    </head>
    <body>
      <div id="container">
        <h1>429 Too Many Requests</h1>
        <p>We're sorry, but you've sent too many requests in a short amount of time.</p>
        <p>Please wait a moment and try again.</p>
        <p>If you believe this is an error, please <a href="mailto:support@example.com">contact support</a>.</p>
        <p><a href="/">Return to Homepage</a></p>
      </div>
    </body>
    </html>
    "};
    return (deliver);
  }

  if (obj.status == 600) {
    set obj.status = 404;
    set obj.http.Content-Type = "text/html";
    synthetic {"<h1>Not Found</h1>"};
    return(deliver);
  }
}
