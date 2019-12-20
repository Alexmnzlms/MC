%option noyywrap

   /*------------------------ Seccion de Declaraciones -------------------------*/
%{
#include <iostream>
#include <fstream>
#include <stack>
#include <string>
using namespace std;
ifstream fichero;
stack<string> pila;
string etiq;
int nf = 0;
bool fallo = false;
%}
palabra [a-zA-Z ""=/0-9;#]

%%
   /*-------------------------- Seccion de Reglas ------------------------------*/
\<\/?{palabra}*\> {
   string cadena(YYText());
   cadena.pop_back();
   cadena.erase(cadena.begin());
   bool borrar = false;
   int tam = cadena.size();
   cout << "Leo la cadena: " << cadena << endl;
   for(string::iterator i = cadena.begin(); i != cadena.end(); i++){
      if(*i == ' '){
         borrar = true;
      }
      if(borrar){
         if(*i != '/'){
            cadena.erase(i);
            i--;
         }
      }
      cout << "Cadena actual: " << cadena << endl;
   }
   cout << "Cambios en la cadena: " << cadena << endl;
   if(cadena[0] != '/'){
      if(cadena.back() != '/'){
         pila.push(cadena);
      } else {
         cout << "Encontrada instruccion autocontenida " << cadena << endl;
      }
      //cout << "Meto en la pila: " << cadena << endl;
   } else{
      cadena.erase(cadena.begin());
      if(!cadena.compare(pila.top())){
         cout << "Has cerrado la etiqueta " << pila.top() << " con " << cadena << endl;
         pila.pop();
      } else {
         cout << "-----------------------------------------------------------" << endl;
         cout << "Has cerrado MAL la etiqueta " << pila.top() << " con " << cadena << endl;
         cout << "-----------------------------------------------------------" << endl;
         fallo = true;
         nf++;
         //exit(1);
      }
      //cout << "Fuera de la pila: " << cadena << endl;
   }
}

. {}
\n {}

%%
   /*----------------------- Seccion de Procedimientos -------------------------*/

int main(int argc, char *argv[]){
   if (argc == 2){
      fichero.open (argv[1]);
   }
   else exit(1);

   yyFlexLexer flujo (&fichero,0);
   flujo.yylex();
   if(!fallo){
      cout << "Ha salido todo bien" << endl;
   } else {
      cout << "Algo ha fallado" << endl;
      cout << "Se han encontrado " << nf << " fallos" << endl;
   }
   cout << "---------LA PILA---------" << endl;
   while(!pila.empty()){
      cout << pila.top() << endl;
      pila.pop();
   }

   return 0;
}
