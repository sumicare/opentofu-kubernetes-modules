/*
   Copyright 2025 Sumicare

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/


resource "kubernetes_secret" "tap_k_8_s_tls" {
  metadata {
    name      = "tap-k8s-tls"
    namespace = "linkerd-viz"

    labels = {
      component              = "tap"
      "linkerd.io/extension" = "viz"
      namespace              = "linkerd-viz"
    }

    annotations = {
      "linkerd.io/created-by" = "linkerd/cli edge-25.8.5"
    }
  }

  data = {
    "tls.crt" = "-----BEGIN CERTIFICATE-----\nMIIDJTCCAg2gAwIBAgIQA+kfoJbR2omit5yz0sW/PTANBgkqhkiG9w0BAQsFADAe\nMRwwGgYDVQQDExN0YXAubGlua2VyZC12aXouc3ZjMB4XDTI1MTEwNTEwMzIyMVoX\nDTI2MTEwNTEwMzIyMVowHjEcMBoGA1UEAxMTdGFwLmxpbmtlcmQtdml6LnN2YzCC\nASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAL352xG3KJSHpcDV38ow1ZW8\nUtVYSpgZQBfj4s2eeuOa0m424B91mEjf9H5C+xqnTju1IAkJWzMWWe/vuJYPwe4s\n8s9KXVqitpqzg9Xf6qAOgcID/ljEZBKHyIzVzWN6cj4tPWtK7Mhp0rIhk0CDPFDm\noWd2ZfQxi9KW6NBdvy5RInuwdxs6J88t8eS1vMXaL6CijqwukBb1Kvh18xH091Jr\nUYLiaBxh6tV8CdPPyZlUwHujCEhKWUtlwgUFfMc9q5wSjEaqz9XFIExGJ1r4ANKR\nSHUvddFzmxnBVUzqrDiePJoKY1zU7E0L8E7zfiOXphmQkLsbjXTwJjDxNJ4GitcC\nAwEAAaNfMF0wDgYDVR0PAQH/BAQDAgWgMB0GA1UdJQQWMBQGCCsGAQUFBwMBBggr\nBgEFBQcDAjAMBgNVHRMBAf8EAjAAMB4GA1UdEQQXMBWCE3RhcC5saW5rZXJkLXZp\nei5zdmMwDQYJKoZIhvcNAQELBQADggEBABolGFE0Mc+7+U0+ex+pbKwk0jGSezgF\n4oE+9/We7ABi+jawLjlkfinXD6a/yl13zuyVvPDrcNMss33+Zu9ckDo8VH/jy3HG\n86wUz6BKgwS/XGNzxjJBwL5YIP5pm5Ifkwd8s0hWJxWaxjGh63WGUOn7zQRpXtqm\nzDcAgHqcy+pYTl4XWt7Mx60rCPTKpMPQSHzzcuPhi8fN6obZnoO0dn7VpE5zWaqb\nXrGhO9YRp3hpC4F+18yG60cMIVQGHqLp+enqG6neELtrl+Sm0Fie7ds/vLP3Ueht\no5ZGHslplBYtuHQxfFgZo26oWXGZJpT2bAKB21SBoXYoM7VMr2mp7Mk=\n-----END CERTIFICATE-----"
    "tls.key" = "-----BEGIN RSA PRIVATE KEY-----\nMIIEogIBAAKCAQEAvfnbEbcolIelwNXfyjDVlbxS1VhKmBlAF+PizZ5645rSbjbg\nH3WYSN/0fkL7GqdOO7UgCQlbMxZZ7++4lg/B7izyz0pdWqK2mrOD1d/qoA6BwgP+\nWMRkEofIjNXNY3pyPi09a0rsyGnSsiGTQIM8UOahZ3Zl9DGL0pbo0F2/LlEie7B3\nGzonzy3x5LW8xdovoKKOrC6QFvUq+HXzEfT3UmtRguJoHGHq1XwJ08/JmVTAe6MI\nSEpZS2XCBQV8xz2rnBKMRqrP1cUgTEYnWvgA0pFIdS910XObGcFVTOqsOJ48mgpj\nXNTsTQvwTvN+I5emGZCQuxuNdPAmMPE0ngaK1wIDAQABAoIBABIQqFxO5nT5UTG9\nJMK9UhIjDl1rP+ymugmLig2zfEwYdNo2LanQLOMBKOa4x9gJAM98sccqNJnvDi5a\nxVq/tNlJPO2pTKdJwcOEPo0f9deyiXRBnPYj9sAsWU3LJvTGuAZhlu2U+l80cOyv\ndKk10Y5/3+lOwPMvovQrlYf64istMgDSK5uYOu5yNwCSDnAH7hHhDBADjPNZWanX\nJogZcuEqJySbGZHkayyFPB89T96Q7m6WsC5TUdfmY5GaZeIgGyfpERKJRxT40c1P\nsUTjU2yZBi/nnujKDWcqFB4MD5WDEvYknOyJGafBxf352CmOZ6/C1c5TSNaguDgJ\nCbaM0wECgYEA3kk9mVCR6yqtUHW/g9fw5f3cegIsNgvqLDyWif7kILQ9gNtVQ3be\n0Bj4FIb21KotIy7gS5sXgtot1DJ1b8mP5StwumIn/Gh0B1TMkZA1tB/JLNbE8zNs\nM2gkFSpX3lO9/cIouKIu6d7B0a0IkT+0xJ6a8+hnRWq3C11rPkr7IzECgYEA2soa\nSK/henqONYeQt7GC1Y5vaGuWB5pk1TIlEGBLNiQNRLXrNItN/Mr1TtTXBYjrRT9n\nwg6oJn6uv9CsqY9XyWWdLcKQ4+4kdGbRYv7SY7SSGUe/rFYFLc453ttBEtdLB5WE\nNgT/zIA5H6DwQoWhGryUxIoIcbJqcjW7ILvvvIcCgYBGOftlEYhYNK52ygyMec+Y\nyeA7B66yEIeWHDovNMEb9/WqXSEN5GM2eXz+9zjKLU1/XRLtr/z4kTeDX8GsZJC6\nhUPjDpm1a8akfkz2/AmLc7NaICwu7aMUhqVHro3+JpTSs+Grm0mZB5BSTwly4h6Z\nM8aeomDmFHXp+ESmdIftMQKBgAkY4DDnh0OVdvZI1b6dlegVTRKVbp6QT+MBe8ML\njfUJWLfjrIz5wdtiAQMvHGWxhL7TXRgXjexT1iZJofRG7oqEPB3b+jRQAZoJcGli\nWRMmPfDpJ9IdnYeDDKr0iOckpo0BLYclfBFfv4BOK89ISSOYdcMaTjGUDpMDIu3A\ngr5fAoGAATxk7DP7LwnUSim2Zg+XagHf53vTczo+LLRKCdzsV+mg7x3LcItVovrF\nhSxPg5U8s/xTy6pJdXttmYI37RBiZqGBC6KCowiXLks1Me0DOvD54BSMfr/1iBMC\ntwjZY51lJYiYNbVJwinGOomJ1cpqVvVGIXnlz4U9sVjmblg3jrg=\n-----END RSA PRIVATE KEY-----"
  }

  type = "kubernetes.io/tls"
}

resource "kubernetes_secret" "tap_injector_k_8_s_tls" {
  metadata {
    name      = "tap-injector-k8s-tls"
    namespace = "linkerd-viz"

    labels = {
      "linkerd.io/extension" = "viz"
    }

    annotations = {
      "linkerd.io/created-by" = "linkerd/cli edge-25.8.5"
    }
  }

  data = {
    "tls.crt" = "-----BEGIN CERTIFICATE-----\nMIIDQDCCAiigAwIBAgIQFa4TTwlAldF9ebUMkc/IbTANBgkqhkiG9w0BAQsFADAn\nMSUwIwYDVQQDExx0YXAtaW5qZWN0b3IubGlua2VyZC12aXouc3ZjMB4XDTI1MTEw\nNTEwMzIyMVoXDTI2MTEwNTEwMzIyMVowJzElMCMGA1UEAxMcdGFwLWluamVjdG9y\nLmxpbmtlcmQtdml6LnN2YzCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEB\nAJk7wU/Nf22Ua3IVQTBlOKtp21FjyUZKD6/Gv9eDMeag+UALlCsy9iuexXPgJFIR\nwB/K6bgc6dCF0IoFWLev86e/jojA/Ye3UbC+8Ub0UpP08FUDn4GBAl9fjKNsPNZP\n5sO/I+R1UaU2e33ukNPD3iFy7py41mE3K9WpdKFzPy61V7T5OQfjy5D1spdHilfu\nRY3S6SBQrGY0xIh4wXN2vkhGzTc/yjsqC2UXzziiV4Z0HDwGSPmSSPBt0F7sR74H\nofMLbfDOIAiZdCyCUcRpwN0syfqQpcJ031fmVDEXJnBU/6vCJEN1w6b71G+/mmXE\nzt763JZuy58yN78Fl/NXJx8CAwEAAaNoMGYwDgYDVR0PAQH/BAQDAgWgMB0GA1Ud\nJQQWMBQGCCsGAQUFBwMBBggrBgEFBQcDAjAMBgNVHRMBAf8EAjAAMCcGA1UdEQQg\nMB6CHHRhcC1pbmplY3Rvci5saW5rZXJkLXZpei5zdmMwDQYJKoZIhvcNAQELBQAD\nggEBAJQfWryH1NtiegWovOhwlbMmLYUI8Psh+Za9iv54KVdQlnEeLWHGXFvAoRsY\nOr5/A1Ep4pdRJat8DTkeKB3r492gxmA8eXgbbXgazDkSSYZPPCBsknUeffkyaG6w\n3i2HPzs8ufWd3XlDNrMJ5U5GSSVf76c6OK2XryjyEuJUWgclucOQT2r95QYxIVp6\nveNSu+p9UJCy99Qmpma2G/hzq6eYVoAZjeZRH3+qMqckZjpfjiiKfbOacIthcCXC\nE4htkRC8h7Yxp7t8Jm/AChYoqq/kh1EC4kgDBmcK2QhOoikMzCkhgDlm/u8RaSJA\naub24IvdhdI8w5CeSokz/ekFc8E=\n-----END CERTIFICATE-----"
    "tls.key" = "-----BEGIN RSA PRIVATE KEY-----\nMIIEowIBAAKCAQEAmTvBT81/bZRrchVBMGU4q2nbUWPJRkoPr8a/14Mx5qD5QAuU\nKzL2K57Fc+AkUhHAH8rpuBzp0IXQigVYt6/zp7+OiMD9h7dRsL7xRvRSk/TwVQOf\ngYECX1+Mo2w81k/mw78j5HVRpTZ7fe6Q08PeIXLunLjWYTcr1al0oXM/LrVXtPk5\nB+PLkPWyl0eKV+5FjdLpIFCsZjTEiHjBc3a+SEbNNz/KOyoLZRfPOKJXhnQcPAZI\n+ZJI8G3QXuxHvgeh8wtt8M4gCJl0LIJRxGnA3SzJ+pClwnTfV+ZUMRcmcFT/q8Ik\nQ3XDpvvUb7+aZcTO3vrclm7LnzI3vwWX81cnHwIDAQABAoIBAAofKVjFITqyyBok\nD0dMGF8yQdtxdPUgpUKeJUPuFZi/X1d8rE/iMOKWvUI3Nw74vzEabS/NMSCmBi1n\nxwFzLOwSui6MWPLjCBFdu4BNWTsOveVPtPSP+gEkxZxx5N7fLkYV1SAdI8R/Ac9C\nt+xVDtI0zlAp4XdQdqPJarvTagQCulgEq08eoVw3tcPbvvO4ctkaETkm8w3IyPm3\nss0vWeQEqOgXmuoVN3b4vvLlLCP5MH42tGxTL1jrxFWYuBlH6VEhCbdUYEOXVk/S\nG5ikgZHv4xMsBayUt/Us6OOH4nXy+607dwCVyVA/btKlef2+vlGL1Tm9kWyatXgk\ncLm/f/ECgYEAwEbgJxH00dHER9rHI418qPxJRv2sf3P1k7LgEftQEKR4JcVMCzqc\nDjeluabnLtfg8bPrkgJsbk4VAAUtQKSHqYM/psG+Z2cxAteP1RoxWmrjBCe8QLzI\nTMtmMjKzQRtA6yiKXt2ip4TImtZ807e1H92e4eMsO5/6K9wLIcH6c0cCgYEAzARc\npLCSC2Dd6vgFeAfr7jPuJTobrWfRoDeLhspme0sSEtnS7NnfNaQtqyVEtQ/z03Wk\nZ6mGgHIGqKYWcueWpLKZSPc7RPZZ14J1COQq55LJNdLiEGwD8ZY06G2jd7QzvXOY\n+hXEVPYZfyNTai2TBWLOeu60NlYkHPxaY2BcqWkCgYEAj8JuRcf/LAGSp8bDralT\n02UNxK5WEtU4f732Gnu0WT0fN95UBPFFTLv+hNhtcXCnFxBWyUxWlgJ7YRB9zR82\n717acGvbWKSm2GEjgUmcLOZN5gVvk1eSyxgoyM9vhvZBi5E8I8HCo018T4ievA1W\ntwSUjn+zysDJ45EaIZtPDnECgYA82/g+8KVAW68XjtEi00ogDsG1vTXQbq3r22X1\n2Z7knKpRkUUIfp3FRKqS6VUrpgyYQfm/KqUC4AD4gkMkF82qZ9SuHYJCujJmxXXg\nJyBdYD5BnhztxSsQADzcMQiYhtsAYuF5iNC+f4Nvl7wkal/3NVhe96Iuq1euheD4\n0CAUMQKBgCeV572oSnkPiG/PhPhLxNKAn0TpwyAKwrKQOK2aHVi4fsm7JFLjjcle\nc3FO0oCdzOGwfJddpRSszRszr2N+aKW7oLsWxhzyesC0SgcpQWq2+r2K0acAdJZS\nuDRhgdHX0d34P3Evi/AAJmA5ADblMaVrdV0vOPDPwIzgNt01K7pX\n-----END RSA PRIVATE KEY-----"
  }

  type = "kubernetes.io/tls"
}

