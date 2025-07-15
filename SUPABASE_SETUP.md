# Supabase Storage Setup Guide

This document provides instructions for setting up the Supabase storage bucket and Row Level Security (RLS) policies for the document management system.

## 🚨 Quick Fix for RLS Error

If you're getting a "row-level security policy" error, run these commands immediately in your Supabase SQL Editor:

```sql
-- Step 1: Enable RLS on storage.objects
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- Step 2: Create a permissive policy for authenticated users (temporary)
CREATE POLICY "Allow all authenticated operations" ON storage.objects
FOR ALL TO authenticated
USING (bucket_id = 'documents' AND auth.uid() IS NOT NULL)
WITH CHECK (bucket_id = 'documents' AND auth.uid() IS NOT NULL);
```

Then test your upload again. If it works, you can proceed with the detailed setup below.

## 1. Create Storage Bucket

In your Supabase dashboard, go to Storage and create a new bucket:

1. Go to Storage > Buckets
2. Click "New bucket"
3. Name: `documents`
4. Make it **Private** (for sensitive data security)
5. Click "Create bucket"

## 2. Set up RLS Policies

Run the following SQL commands in your Supabase SQL Editor:

### Enable RLS on the storage.objects table
```sql
-- Enable RLS on storage.objects
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;
```

### Create comprehensive policies for secure document access
```sql
-- Policy: Allow authenticated users to upload files to their own folders
CREATE POLICY "Allow authenticated uploads" ON storage.objects
FOR INSERT TO authenticated
WITH CHECK (
  bucket_id = 'documents' AND 
  auth.uid() IS NOT NULL
);

-- Policy: Allow users to view files they uploaded or have access to
CREATE POLICY "Allow authenticated downloads" ON storage.objects
FOR SELECT TO authenticated
USING (
  bucket_id = 'documents' AND 
  auth.uid() IS NOT NULL
);

-- Policy: Allow users to update their own files
CREATE POLICY "Allow authenticated updates" ON storage.objects
FOR UPDATE TO authenticated
USING (
  bucket_id = 'documents' AND 
  auth.uid() IS NOT NULL AND
  auth.uid()::text = owner
);

-- Policy: Allow users to delete their own files
CREATE POLICY "Allow authenticated deletes" ON storage.objects
FOR DELETE TO authenticated
USING (
  bucket_id = 'documents' AND 
  auth.uid() IS NOT NULL AND
  auth.uid()::text = owner
);
```

### Alternative: More permissive policies for testing (still secure)
If you need broader access during development:

```sql
-- Drop existing policies first
DROP POLICY IF EXISTS "Allow authenticated uploads" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated downloads" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated updates" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated deletes" ON storage.objects;

-- More permissive policies for authenticated users
CREATE POLICY "Allow all authenticated operations" ON storage.objects
FOR ALL TO authenticated
USING (bucket_id = 'documents' AND auth.uid() IS NOT NULL)
WITH CHECK (bucket_id = 'documents' AND auth.uid() IS NOT NULL);
```

### Temporary: Disable RLS for initial testing only
**⚠️ WARNING: Only use this temporarily for debugging, never in production!**

```sql
-- Disable RLS temporarily (NOT recommended for production)
ALTER TABLE storage.objects DISABLE ROW LEVEL SECURITY;

-- Remember to re-enable it after testing:
-- ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;
```

## 3. Verify Setup

After setting up the policies, test the upload functionality:

1. Make sure you're logged in to the app
2. Try uploading a document
3. Check the browser console for detailed logs
4. Verify the file appears in Supabase Storage

## 4. Troubleshooting

### Common Issues:

1. **403 Unauthorized Error**: 
   - Check if RLS policies are correctly set up
   - Verify the user is authenticated (`auth.uid()` is not null)
   - Ensure the bucket is properly configured
   - Try the more permissive policy temporarily

2. **Bucket not found**:
   - Verify the bucket exists in Supabase Storage
   - Check the bucket name in the code matches exactly (`documents`)

3. **Policy conflicts**:
   - Review existing policies that might conflict
   - Drop and recreate policies if needed
   - Test with RLS temporarily disabled

### Debug Commands:

```sql
-- Check existing policies
SELECT * FROM pg_policies WHERE tablename = 'objects' AND schemaname = 'storage';

-- Check if RLS is enabled
SELECT tablename, rowsecurity FROM pg_tables WHERE schemaname = 'storage' AND tablename = 'objects';

-- View bucket configuration
SELECT * FROM storage.buckets WHERE name = 'documents';

-- Check current user authentication
SELECT auth.uid(), auth.email();
```

## 5. Production Security Considerations

For production with sensitive data:

1. **Private Bucket**: Always use private buckets for sensitive documents
2. **Granular RLS Policies**: Implement role-based access control
3. **File Encryption**: Consider client-side encryption for highly sensitive data
4. **Access Logging**: Monitor all file access and downloads
5. **Regular Audits**: Review access patterns and permissions
6. **Backup Security**: Ensure backups are also properly secured

### Advanced RLS Policy Example (Role-based):
```sql
-- Example: Role-based access policy
CREATE POLICY "Role based access" ON storage.objects
FOR SELECT TO authenticated
USING (
  bucket_id = 'documents' AND 
  auth.uid() IS NOT NULL AND
  (
    -- Admin users can access everything
    auth.jwt() ->> 'user_role' = 'admin' OR
    -- Managers can access their department files
    (auth.jwt() ->> 'user_role' = 'manager' AND 
     name LIKE '%/' || (auth.jwt() ->> 'department') || '/%') OR
    -- Regular users can only access their own files
    auth.uid()::text = owner
  )
);
```

## 6. Next Steps

Once storage is working securely:
1. Test folder creation with proper permissions
2. Test document downloads with signed URLs
3. Implement proper user role-based access in your app
4. Add file type and size validations 
5. Set up audit logging for compliance 