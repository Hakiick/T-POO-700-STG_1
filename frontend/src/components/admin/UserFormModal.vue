<script setup lang="ts">
import { ref, watch } from 'vue'
import { type User } from '@/components/store/userStore'
import ResponsiveModal from '@/components/ui/modal/ResponsiveModal.vue'
import Button from '@/components/ui/button/Button.vue'
import Input from '@/components/ui/input/Input.vue'
import Label from '@/components/ui/label/Label.vue'

interface Props {
  open: boolean
  user: User | null
}

const props = defineProps<Props>()

const emit = defineEmits<{
  'update:open': [value: boolean]
  save: [data: { username: string; email: string }]
}>()

const username = ref('')
const email = ref('')
const usernameError = ref('')
const emailError = ref('')

watch(
  () => props.open,
  (isOpen) => {
    if (isOpen) {
      username.value = props.user?.username ?? ''
      email.value = props.user?.email ?? ''
      usernameError.value = ''
      emailError.value = ''
    }
  },
)

function validateForm(): boolean {
  let valid = true
  usernameError.value = ''
  emailError.value = ''

  if (!username.value.trim()) {
    usernameError.value = 'Username is required'
    valid = false
  }

  if (!email.value.trim()) {
    emailError.value = 'Email is required'
    valid = false
  } else {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    if (!emailRegex.test(email.value)) {
      emailError.value = 'Invalid email format'
      valid = false
    }
  }

  return valid
}

function handleSave() {
  if (!validateForm()) return

  emit('save', {
    username: username.value.trim(),
    email: email.value.trim(),
  })
}
</script>

<template>
  <ResponsiveModal
    :open="open"
    :title="user ? 'Edit User' : 'Create User'"
    @update:open="emit('update:open', $event)"
  >
    <form class="space-y-4" @submit.prevent="handleSave">
      <div class="space-y-2">
        <Label for="user-username">Username</Label>
        <Input
          id="user-username"
          v-model="username"
          placeholder="Enter username"
          class="w-full"
          :class="{ 'border-destructive': usernameError }"
        />
        <p v-if="usernameError" class="text-sm text-destructive">
          {{ usernameError }}
        </p>
      </div>

      <div class="space-y-2">
        <Label for="user-email">Email</Label>
        <Input
          id="user-email"
          v-model="email"
          type="email"
          placeholder="Enter email"
          class="w-full"
          :class="{ 'border-destructive': emailError }"
        />
        <p v-if="emailError" class="text-sm text-destructive">
          {{ emailError }}
        </p>
      </div>

      <div class="flex gap-3 pt-2">
        <Button
          type="button"
          variant="outline"
          class="flex-1 min-h-touch"
          @click="emit('update:open', false)"
        >
          Cancel
        </Button>
        <Button
          type="submit"
          class="flex-1 min-h-touch"
        >
          {{ user ? 'Save Changes' : 'Create User' }}
        </Button>
      </div>
    </form>
  </ResponsiveModal>
</template>
