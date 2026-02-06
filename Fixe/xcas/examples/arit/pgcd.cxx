/* Algorithme d'Euclide */
pgcd0(P,Q):={
  local R;
  for (;Q!=0;){
  R:=rem(P,Q);
  P:=Q;
  Q:=R;
  }
  return P;
};

/* Avec pseudo-division */
pgcd1(P,Q):={
  local R,a,dd;
  for (;Q!=0;){
  a:=lcoeff(Q);
  dd:=degree(P)-degree(Q)+1;
  R:=rem(a^dd*P,Q);
  P:=Q;
  Q:=R;
  }
  return P;  
};

/* Avec extraction des contenus */
pgcd2(a,b):={ 
  local P,p,Q,q,R,g,h,d;
  // convertit a et b en polynomes listes et extrait la partie primitive   
  P:=symb2poly(a);
  p:=lgcd(P); // pgcd des elements de la liste
  P:=P/p; 
  Q:=symb2poly(b);
  q:=lgcd(Q);
  Q:=Q/q; 
  if (size(P)<size(Q)){ // echange P et Q
    R:=P; P:=Q; Q:=R; 
  } 
  // calcul du contenu du pgcd
  p:=gcd(p,q);
  g:=1;
  h:=1;
  while (size(Q)!=1){
    q:=Q[0]; // coefficient dominant
    d:=size(P)-size(Q);
    R:=rem(q^(d+1)*P,Q);
    if (size(R)==0) 
      return(p*poly2symb(Q/lgcd(Q),x));
    P:=Q;
    Q:=R/lgcd(R);
    print(Q);
  } 
  return(p);
};

/* Sous-resultant */
pgcd3(a,b):={ 
  local P,p,Q,q,R,g,h,d;
  // convertit a et b en polynomes listes et extrait la partie primitive   
  P:=symb2poly(a);
  p:=lgcd(P); // pgcd des elements de la liste
  P:=P/p; 
  Q:=symb2poly(b);
  q:=lgcd(Q);
  Q:=Q/q; 
  if (size(P)<size(Q)){ // echange P et Q
    R:=P; P:=Q; Q:=R; 
  } 
  // calcul du contenu du pgcd
  p:=gcd(p,q);
  g:=1;
  h:=1;
  while (size(Q)!=1){
    q:=Q[0]; // coefficient dominant
    d:=size(P)-size(Q);
    R:=rem(q^(d+1)*P,Q);
    if (size(R)==0) 
      return(p*poly2symb(Q/lgcd(Q),x));
    P:=Q;
    Q:=R/(g*h^d);
    print(Q);
    g:=q; h:=q^d/h^(d-1);
  } 
  return(p);
};

P1:=(x+1)^7-(x-1)^6;
Q1:=diff(P1);
P2:=(x+1)^20-(x-1)^19;
Q2:=diff(P2);
P3:=(x+1)^7*(x-1)^6;
Q3:=diff(P3);
/* Tester pgcd0,1,2,3 de P1,Q1 P2,Q2 et P3,Q3 puis gcd(P1%3,Q1%3) puis P3,Q3 
   Tester P3|x=42, Q3|x=42, pgcd puis genpoly(,42,x) */
