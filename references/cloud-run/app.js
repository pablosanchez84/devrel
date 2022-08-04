/**
 * Copyright 2021 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

const express = require('express');
const jwt = require('express-jwt');
const jwksRsa = require('jwks-rsa');

const app = new express();

app.use(jwt({
  // Dynamically provide a signing key based on the kid in the header and the signing keys provided by the JWKS endpoint.
  secret: jwksRsa.expressJwtSecret({
    cache: true,
    rateLimit: true,
    jwksRequestsPerMinute: 5,
    jwksUri: 'https://www.googleapis.com/oauth2/v3/certs'
  }),

  // Validate the audience and the issuer.
  audience: '407408718192.apps.googleusercontent.com',
  issuer: 'https://accounts.google.com',
  algorithms: [ 'RS256' ],
  getToken: function fromHeader (req) {
    if (req.headers['x-openid'] && req.headers['x-openid'].split(' ')[0] === 'Bearer') {
        return req.headers['x-openid'].split(' ')[1];
    }
    return null;
  }
}));

app.get('/', (req, res) => {
  //res.send(`Hello from Apigee`);
  res.send('Hello from Cloud Run, token data is ' + JSON.stringify(req.user));
});

const port = process.env.PORT || 8080;
app.listen(port, () => {
  console.log(`helloworld: listening on port ${port}`);
});