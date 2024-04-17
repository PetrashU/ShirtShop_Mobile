const express = require('express');
const bodyParser = require('body-parser');
const admin = require('firebase-admin');
const bcrypt = require('bcrypt');
const { getStorage } = require('firebase-admin/storage');

const app = express();
app.use(bodyParser.json());

const serviceAccount = require('./f/crud-20482-firebase-adminsdk-v3nd9-cf91e4c306.json');
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  storageBucket: "crud-20482.appspot.com"
});

const db = admin.firestore();

app.get('/shirts', async (req, res) => {
  try {
    const shirtsSnapshot = await db.collection('shirts').get();
    const shirts = [];
    shirtsSnapshot.forEach(doc => {
      shirts.push({ id: doc.id, ...doc.data() });
    });
    res.status(200).json(shirts);
  } catch (error) {
    res.status(500).send(error.toString());
  }
});

app.post('/shirts', async (req, res) => {
  try {
    const uniqueId = Date.now();
    const { color, text, photoUrl } = req.body;
    const newShirt = { id: uniqueId, color, text, photoUrl};
    
    await db.collection('shirts').doc(uniqueId.toString()).set(newShirt);
    res.status(201).send(newShirt);
  } catch (error) {
    res.status(500).send(error.toString());
  }
});

app.put('/shirts/:id', async (req, res) => {
  try {
    const { color, text, photoUrl } = req.body;
    const shirtRef = db.collection('shirts').doc(req.params.id);
    
    await shirtRef.update({ color, text, photoUrl });
    
    const updatedShirtSnapshot = await shirtRef.get();
    const updatedShirt = { id: updatedShirtSnapshot.id, ...updatedShirtSnapshot.data() };
    
    res.status(200).send(updatedShirt);
  } catch (error) {
    res.status(500).send(error.toString());
  }
});

app.delete('/shirts/:id', async (req, res) => {
  try {
    const deletedShirtRef = db.collection('shirts').doc(req.params.id);
    const deletedShirt = await deletedShirtRef.get();
    
    await deletedShirtRef.delete();
    
    res.status(200).send({ id: deletedShirt.id, ...deletedShirt.data() });
  } catch (error) {
    res.status(500).send(error.toString());
  }
});

app.post('/users/register', async (req, res) => {
  try {
    const { email, username, password } = req.body;
    const usersRef = db.collection('users');

    const emailCheck = await usersRef.where('email', '==', email).get();
    if (!emailCheck.empty) {
      return res.status(400).send('Email already used');
    }

    const usernameCheck = await usersRef.where('username', '==', username).get();
    if (!usernameCheck.empty) {
      return res.status(400).send('Username already taken');
    }

    const hashedPassword = bcrypt.hashSync(password, 10);
    const userId = Date.now();

    const newUser = { id: userId, email, username, password: hashedPassword, isAdmin: false };
    await usersRef.doc(userId.toString()).set(newUser);

    res.status(201).send({ id: userId, username, email });
  } catch (error) {
    res.status(500).send(error.toString());
  }
});

app.post('/users/login', async (req, res) => {
  try {
    const { username, password } = req.body;
    const usersRef = db.collection('users');
    const querySnapshot = await usersRef.where('username', '==', username).get();

    if (querySnapshot.empty) {
      return res.status(400).send('Invalid credentials');
    }

    const user = querySnapshot.docs[0].data();
    if (!bcrypt.compareSync(password, user.password)) {
      return res.status(400).send('Invalid credentials');
    }

    const { password: _, ...userInfo } = user;
    res.status(200).send(userInfo);
  } catch (error) {
    res.status(500).send(error.toString());
  }
});

const multer = require('multer');
const upload = multer({ dest: 'uploads/' });

app.post('/upload', upload.single('file'), async (req, res) => {
  try {
      const file = req.file;
      const bucket = admin.storage().bucket();
      
      const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
      const fileName = `images/${uniqueSuffix}-${file.originalname}`;

      await bucket.upload(file.path, {
          destination: fileName,
      });

      
      const url = await bucket.file(fileName).getSignedUrl({
          action: 'read',
          expires: '03-09-2491',
      });

      res.status(200).send({ url: url[0] });
  } catch (error) {
      console.error(error);
      res.status(500).send(error.toString());
  }
});


app.post('/deletephoto', async (req, res) => {
  try {
    const { oldFileUrl } = req.body;
    const bucket = admin.storage().bucket();

    const oldFileName = oldFileUrl.split('/').pop().split('?')[0];

    if (!oldFileName) {
      return res.status(400).send('Missing oldFileName');
    }

    const fileName = `images/${oldFileName}`;

    const fileExists = await bucket.file(fileName).exists();

    if (!fileExists[0]) {
      return res.status(404).send('File not found');
    }

    await bucket.file(fileName).delete();

    res.status(200).send('Photo deleted');
  } catch (error) {
    console.error(error);
    res.status(500).send(error.toString());
  }
});



const PORT = process.env.PORT || 3000;
app.listen(PORT, '0.0.0.0', () => {
	  console.log(`Server is running on port ${PORT}`);
});
