# catalog

Organizando a facilidade.

## Sobre

O Catalog está sendo desenvolvido para apresentação no Inova CPS.

O intuito do aplicativo é ser desenvolvido utilizando as ferramentas do Google. Como linguagem estou utilizando Flutter e no banco de dados Firebase Database e Storage. O aplicativo também conta com o sistema de autenticação Firestore Authentication.

A necessidade que queremos sanar é a de catalogação de itens contidos em embalagens e organização dos mesmos sem a necessidade de abertura da embalagem em questão, ou seja, poderá ser descoberto o conteúdo sem a necessidade de manejos. Isso será feito com um QR Code ou Barcode fixado no exterior da embalagem, assim podendo ser escaneado na aplicação que exibirá seu conteúdo. Os QR Codes e Barcodes gerados poderão somente ser escaneados em um aplicativo Catalog e conta também com criptografia protegida por senha caso o conteúdo seja confidencial.

Caso haja a necessidade de alteração do conteúdo ou remoção de itens, isso poderá ser feito no aplicativo sem a necessidade de criação de um novo QR Code, pois eles contam com ID único global.

## Estrutura de dados

O sistema de autenticação atual conta com duas formas de registro e entrada, sendo e-mail e senha e também Google. A estrutura abaixo é de um usuário com as duas formas ativas que se mesclam automaticamente no Firebase Authentication assim reduzindo a chance de usuários duplicados. 

```JSON
{"users": [
{
  "localId": "Vx9oJZ6J1ENAbqTqQ27gORxrrJ92",
  "email": "oggimrm@gmail.com",
  "emailVerified": true,
  "displayName": "Fabricio Amorim",
  "photoUrl": "https://lh3.googleusercontent.com/a/ALm5wu1XQ_CjGXqu9aAc0cAijo1H4-4MhH2Fquu3rMeKkco=s96-c",
  "lastSignedInAt": "1669754622129",
  "createdAt": "1667929188871",
  "providerUserInfo": [
    {
      "providerId": "google.com",
      "rawId": "112329738580144281097",
      "email": "oggimrm@gmail.com",
      "displayName": "Fabricio Amorim",
      "photoUrl": "https://lh3.googleusercontent.com/a/ALm5wu1XQ_CjGXqu9aAc0cAijo1H4-4MhH2Fquu3rMeKkco=s96-c"
    }
  ]
}
]}
```
