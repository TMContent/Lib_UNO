# Applies To

*   Web services and applications

# Summary

During HTTP replay attacks, an adversary records and then replays an HTTP data transmission (sequence of HTTP packets). The most common purpose of this attack is to bypass authentication in order for the adversary to masquerade themselves as a legitimate user.

The following steps are recommended in order to test for HTTP replay attacks:

*   Step 1: Understand Attack Scenarios.
*   Step 2: Analyze Root Causes and Mitigations.
*   Step 3: Start Testing and Exploring.
*   Step 4: Tune Test Cases.

# Step 1: Understand Attack Scenarios

First, you need to understand the fundamental details of an HTTP replay attack. The following scenario illustrates two common purposes for replay attacks:

*   Replay Attack to Bypass Authentication.
*   Replay Attack to Repeat a Transaction.

## Replay Attack to Bypass Authentication

During this scenario, a user (Bob) authenticates to a web application by submitting his email address and password. The attacker (Eve) sniffs the network traffic between Bob and the web application and saves the HTTP packets exchanged during authentication (validating the user). Eve then starts an HTTP connection with the web application and retransmits (replays) the sequence of saved packets (from Bob's authentication) to the server. The server allows Eve to enter the application confusing her as Bob.

In detail:

1.  The attacker discovers a vulnerable web application.
2.  The attacker decides on what client(s) to attack.
3.  The attacker sniffs or monitors HTTP traffic between the victim and the server.
4.  The attacker captures and saves HTTP packets for the victim and server authentication process.
5.  The attacker starts an HTTP connection with the server.
6.  The attacker sends the captured packets (victim's auth packets) to server.

## Replay Attack to Repeat a Transaction

In the second scenario the attacker's goal is to execute an action in addition to bypassing authentication. During this scenario, the attacker also intercepts network traffic between an HTTP client and server. While monitoring the traffic, the attacker captures and saves packets that represent a specific transaction, or which store certain information about these packets. The attacker then connects to a vulnerable server (this can be the same server he sniffed from or another server susceptible to this vulnerability). Finally the attacker sends the saved packets (or new packets containing the specific data from the saved packets) in order to carry out a particular transaction such as purchasing items or modifying account information.

In detail:

1.  The attacker discovers a vulnerable web application.
2.  The attacker decides on what client victim(s) to attack.
3.  The attacker decides what transaction to carry out
4.  The attacker decides on what client or clients to attack depending on the transaction he has in mind.
5.  The attacker sniffs or monitors HTTP traffic between the victim(s) and the server (note in this case, it can be a different server than the server used to obtain the packets used in first place).
6.  The attacker captures and saves HTTP packets or particular parts of packets that he will later use to execute the fraudulent transaction.
7.  The attacker starts an HTTP connection with the vulnerable server.
8.  The attacker replays the saved packets or sends new packets with particular information crafted from the sniffed data to carry out the fraudulent transaction on the victim's behalf.

# Step 2: Analyze Root Cause and Mitigations

Once you understand replay attack scenarios, the next step is to analyze what causes them. In doing so, you will also learn how applications protect against this attack. Knowing the root cause of security vulnerabilities helps you to identify them in both design and implementation (source code). In addition, understanding mitigations in detail tells you if the bug exists when you have the source code available. When lacking source code access, knowing the mitigation techniques helps to guide security testing for this bug; any poorly implemented mitigation will lead to an HTTP replay vulnerability.

## Root Cause

The cause for this bug is that HTTP systems perform legitimate new actions based on reused data. For instance, as seen in the first scenario above, a server performs a legitimate new action (authenticate the attacker as the victim) based on reused data (captured victim auth packets).

## Mitigations

A web service can choose to protect against replay bugs by using session tokens. Before the client sends his email and password to the service, the client and server exchange a session token. The password is hashed with the new session token before sending it to the server. Since the server knows the password and the session token, it computes the hash separately and compares it against the hash value sent by the client. The attacker receives a new session token when they connect to the server to execute the attack. The attacker sends the previously captured password hash to the server but the server denies authentication because the attacker's sessions token is not valid. A server can also prevent replay attacks using a nonce (number used once) along with Message Authentication Code (MAC). The MAC is a hash of the nonce and the password along with a secret key for the transaction. The server computes its own MAC since it knows the nonce, password, and transaction key and validates the client using its internal value.

Another common mitigation is by using timestamps. If the attacker attempts to replay a transaction, the server realizes that the timestamp is from the past and rejects the replay attack.

Applications can also use TLS to protect against replay attacks. During TLS authentication the client and server use random data to generate the key for a specific connection. Each message contains a MAC with the message's sequence number and the connection key. An attacker will not be able to compute a valid MAC without knowing the connection key.

# Step 3: Start Testing and Exploring

Now that you've learned how HTTP replay attacks work and the reasons they exist, you must test for both secure and insecure implementations.

## Basic HTTP replay test

The following steps illustrate how to test for HTTP replay attack bugs:

1.  Start capturing network traffic using _Wireshark_ or a similar network sniffer (since you will use _WebScarab_ to replay the packets you can use it for this step too).
2.  Open a browser and log in to the application site.
3.  Stop capturing packets and save the HTTP packets that deal with authentication.
4.  Log out of the application site and close the browser.
5.  Start intercepting packets using _WebScarab_.
6.  Repeat step 2\.
7.  Before the log in packet leaves your client machine, modify the contents of it with the packet contents saved in step 5.

Expected result: The server recognizes the second log in attempt as a replay attack and denies access to the client's account.

It is important that you understand the different server responses that a replay attack might generate.

## Check if your application uses timestamps, session tokens, or nonces

1.  Start capturing network traffic using _Wireshark_ or similar tool (you can use _WebScarab_ here too).
2.  Open browser and log in to application site.
3.  Save the capture of the log in process.
4.  Analyze network packets and look for some indicator of a timestamp, a session token, or a nonce.

Expected result: The application server uses a timestamp, a session token, or nonce during authentication. Although this is a clear indicator that your application should prevent replay attacks, you should still replay this packet as in the previous test to see if this prevention actually works.

## Test to check if the site uses TLS

1.  Start capturing network traffic using _Wireshark_ or a similar tool.
2.  Open a browser and log in to the application site.
3.  Save the capture of the log in process in _Wireshark_.
4.  Use _Wireshark_ (or a similar tool) to set a capture filter to show only TLS packets.

Expected result: The server uses TLS for authentication and you can see an TLS handshake.

# Step 4: Tune Test Cases

During this step you must test for additional payloads of this attack. For example, record a specific transaction such as a purchase of an item or of specific services. Then try to replay the transaction from outside a valid user session (without legitimate authentication). There are multiple replay attacks that you can try depending on what you have in mind. Make sure to cover the following attacks (these are examples; specific scenarios relevant to your application should be tested):

*   Bypassing authentication.
*   Purchasing an item.
*   Purchasing a service.
*   Viewing protected or confidential documents.

Remember that to properly test for these different attacks you will need to record a specific sequence of packets and then retransmit the content of these packets to the application under test. You can continue using _WebScarab_ or switch to a tool such as TCPReplay in order to replay HTTP sequences of more than one packet.

# Conclusions

Testing for replay attacks is necessary when securing any web application or service. Start by understanding the anatomy of replay attacks. Continue by learning how HTTP replay attacks are prevented, and see if your application uses any of these prevention methods. If it doesn't, then the application is most likely to fail the basic test described in step 3 and be vulnerable to HTTP replay vulnerabilities. For proper coverage, make sure to test the different mitigations and prevention mechanisms. Finally, tune your test case data based on different payloads and transactions you want to execute as replay attacks.