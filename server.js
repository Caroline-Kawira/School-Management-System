const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();
app.use(cors());
app.use(express.json());

// Basic health check route for your group to test
app.get('/', (req, res) => {
    res.send('School Records Backend API is officially running!');
});

// Student personal details route
app.post('/api/students', (req, res) => {
    const { first_name, last_name, email } = req.body;
    res.status(201).json({
        message: "Student profile received successfully!",
        student: { first_name, last_name, email }
    });
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));