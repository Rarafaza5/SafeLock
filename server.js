const express = require('express');
const http = require('http');
const { Server } = require('socket.io');

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: { origin: '*', methods: ['GET', 'POST'] },
  pingTimeout: 60000,
  pingInterval: 25000,
});

const RELAY_SECRET = process.env.RELAY_SECRET || 'safelock-secret-muda-isto-2024';
const PORT = process.env.PORT || 3000;

// Estado: um admin, um agent (por clientId)
const admins = new Map();   // socketId → socket
const agents = new Map();   // clientId → socket

const ts = () => new Date().toISOString();

// ─── Health check ─────────────────────────────────────────
app.get('/', (req, res) => {
  res.json({
    status: 'ok',
    name: 'SafeLock Relay Server',
    version: '1.0.0',
    agents: agents.size,
    admins: admins.size,
  });
});

// ─── Autenticação middleware ───────────────────────────────
io.use((socket, next) => {
  const { token, role } = socket.handshake.auth;
  if (token !== RELAY_SECRET) return next(new Error('AUTH_FAILED'));
  if (!['admin', 'agent'].includes(role)) return next(new Error('INVALID_ROLE'));
  socket.role = role;
  socket.clientId = socket.handshake.auth.clientId || 'default';
  next();
});

// ─── Conexões ─────────────────────────────────────────────
io.on('connection', (socket) => {
  console.log(`[${ts()}] ${socket.role} conectado → ${socket.id} (clientId: ${socket.clientId})`);

  if (socket.role === 'admin') {
    admins.set(socket.id, socket);

    // Informa admin quais agents estão online
    const agentList = [];
    agents.forEach((_, clientId) => agentList.push({ clientId, online: true }));
    socket.emit('agents_status', agentList);

  } else if (socket.role === 'agent') {
    // Desliga agent antigo com mesmo clientId (reconexão)
    const existing = agents.get(socket.clientId);
    if (existing && existing.id !== socket.id) existing.disconnect(true);
    agents.set(socket.clientId, socket);

    // Notifica todos os admins
    admins.forEach((adminSocket) => {
      adminSocket.emit('agent_connected', { clientId: socket.clientId });
    });

    console.log(`[${ts()}] Agent registado: ${socket.clientId}`);
  }

  // ─── Reencaminhar mensagens ──────────────────────────────
  socket.onAny((event, data) => {
    // Ignorar eventos de sistema
    if (['connect', 'disconnect', 'error', 'connect_error'].includes(event)) return;

    if (socket.role === 'admin') {
      // Admin → Agent (usa clientId do payload ou o primeiro disponível)
      const targetId = (data && data.clientId) || agents.keys().next().value;
      const agent = agents.get(targetId);
      if (agent) {
        agent.emit(event, data);
      } else {
        socket.emit('error_response', { error: 'Agent offline', event });
      }

    } else if (socket.role === 'agent') {
      // Agent → todos os Admins
      admins.forEach((adminSocket) => {
        adminSocket.emit(event, { ...data, clientId: socket.clientId });
      });
    }
  });

  // ─── Desconexão ─────────────────────────────────────────
  socket.on('disconnect', (reason) => {
    console.log(`[${ts()}] ${socket.role} desconectado: ${reason}`);

    if (socket.role === 'admin') {
      admins.delete(socket.id);

    } else if (socket.role === 'agent') {
      agents.delete(socket.clientId);
      admins.forEach((adminSocket) => {
        adminSocket.emit('agent_disconnected', { clientId: socket.clientId });
      });
    }
  });
});

server.listen(PORT, () => {
  console.log(`✅ SafeLock Relay a correr na porta ${PORT}`);
});
