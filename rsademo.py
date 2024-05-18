import random
def is_prime(n,k=5):
 if n<2:return False
 for p in[2,3,5,7,11,13,17,19,23,29]:
  if n<p*p:return n>1
  if n%p==0:return False
 s,d=0,n-1
 while d%2==0:d,s=d>>1,s+1
 for i in range(k):
  x=pow(random.randint(2,n-2),d,n)
  if x==1 or x==n-1:continue
  for r in range(1,s):
   x=pow(x,2,n)
   if x==n-1:break
  else:return False
 return True
p=random.randint(2**1023,2**1024-1)
while not is_prime(p):p=random.randint(2**1023,2**1024-1)
q=random.randint(2**1023,2**1024-1)
while not is_prime(q):q=random.randint(2**1023,2**1024-1)
print(p*q)
