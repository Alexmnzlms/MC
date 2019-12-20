%option noyywrap
%option yylineno

   /*------------------------ Seccion de Declaraciones -------------------------*/
%{
#include <iostream>
#include <fstream>
#include <stack>
#include <string>
using namespace std;
ifstream fichero;
stack<string> pila;
stack<int> linea;
string etiq;
int nf = 0;
int la = 0, lc = 0;
bool fallo = false;
%}
palabra [a-zA-Z ""=/0-9;#:.-]

%%
   /*-------------------------- Seccion de Reglas ------------------------------*/
\<\/?{palabra}*\/\> {
   string cadena(YYText());
   cadena.pop_back();
   cadena.erase(cadena.begin());
   cout << "Leo la cadena autocontenida: <" << cadena << "> en la linea " << yylineno << endl;
}

\<\/?{palabra}*\> {
   string cadena(YYText());
   cadena.pop_back();
   cadena.erase(cadena.begin());
   bool borrar = false;
   int tam = cadena.size();
   cout << "Leo la cadena: <" << cadena << "> en la linea " << yylineno << endl;
   for(string::iterator i = cadena.begin(); i != cadena.end(); i++){
      if(*i == ' '){
         borrar = true;
      }
      if(borrar){
         cadena.erase(i);
         i--;
      }
      //cout << "Cadena actual: " << cadena << endl;
   }
   //cout << "Cambios en la cadena: " << cadena << endl;
   if(cadena[0] != '/'){
      la = yylineno;
      linea.push(la);
      pila.push(cadena);
      //cout << "Meto en la pila: " << cadena << endl;
   } else{
      lc = yylineno;
      cadena.erase(cadena.begin());
      if(pila.empty()){
         cout << "PILA VACIA -- NINGUNA CADENA ABIERTA" << endl;
         exit(1);
      }
      if(!cadena.compare(pila.top())){
         la = linea.top();
         cout << "----------------------------------------------------------------------------------------------" << endl;
         cout << "Has cerrado la etiqueta <" << pila.top() << "> en la linea " <<
         la << " con <" << cadena << "> en la linea " << lc << endl;
         cout << "----------------------------------------------------------------------------------------------" << endl;
         pila.pop();
         linea.pop();
      } else {
         cout << "----------------------------------------------------------------------------------------------" << endl;
         cout << "Has cerrado MAL la etiqueta <" << pila.top() << "> con <" << cadena << "> en la linea " << lc << endl;
         cout << "----------------------------------------------------------------------------------------------" << endl;
         fallo = true;
         nf++;
         exit(1);
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
   if(pila.empty()){
      cout << "No queda nada en la pila" << endl;
   } else {
      while(!pila.empty()){
         cout << "Ha quedado la etiqueta <" << pila.top() << "> en la linea " <<
         linea.top() << endl;
         pila.pop();
         linea.pop();
      }
   }
   return 0;
}
