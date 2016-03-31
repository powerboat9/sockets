Server --> Client: displayMe --Contains a random g and p, and A for Dill-Hellman, and data about self
Server <-- Client: attemptConnect --Contains B for Dill-Heffman, data about self, and a verifyKey
Server --> Client: connect --Contains hash(verifyKey .. numbToHex(k)) where k is the key from the Dill-Hellman
